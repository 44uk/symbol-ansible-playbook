#!/bin/bash
#
# スクリプトを直接実行する場合
#   curl -sL https://gist.githubusercontent.com/44uk/48f582ecf4611e493f2acb004dc269c4/raw/symbol-testnet-bootstrap-setup.sh | sudo bash
#

# -------------------------------------------------------------
PRESET=testnet
ASSEMBLY=dual
FRIENDLY_NAME=niz-dual-1_0.3.0
HOST=
USE_HTTPS=
AUDIT=
# -------------------------------------------------------------
USE_SWAP=on
SSHD_PORT=50022
USER=symbol
PSWD=sekoya # 変更を推奨
# -------------------------------------------------------------
# https://github.com/docker/compose/tags
DOCKER_COMPOSE_VER=1.27.4
# https://www.npmjs.com/package/symbol-bootstrap
SYMBOL_BOOTSTRAP_VER=0.3.0
# -------------------------------------------------------------
APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
# -------------------------------------------------------------

USER_HOME="/home/$USER"
BOOTSTRAP_HOME="$USER_HOME/platform"
[ "$ASSEMBLY" = "dual" ] && ROLE=api || ROLE=peer

# Create Swap 2GB
if [ "$USE_SWAP" = "on" ]; then
  fallocate -l 8G /var/swapfile
  chmod 600 /var/swapfile
  mkswap /var/swapfile
  swapon /var/swapfile
  echo '/var/swapfile none swap defaults 0 0' >> /etc/fstab

  ## How to remove swapfile
  # swapoff /var/swapfile
  # rm /var/swapfile
  # sed -i '/\/var\/swapfile/d' /etc/fstab
fi

# Upgrade packages
apt-get upgrade -y

# Remove needless packages
apt-get remove --purge -y \
  apport \
  byobu \
  ftp \
  nano \
  screen \
  tmux \
  telnet

# Install utility packages
apt-get install -y \
  curl \
  python3-pip

# Install docker
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -y && apt-get install -y docker-ce docker-ce-cli containerd.io

# Install docker-compose
curl -sL https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VER/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Set docker daemon setting
# echo '{"log-driver":"json-file","log-opts":{"max-size":"100k","max-file":"3"}}' > /etc/docker/daemon.json
echo '{"log-driver":"journald","log-opts":{"tag":"docker/{{.ImageName}}/{{.Name}}"}}' > /etc/docker/daemon.json
systemctl restart docker

# Install latest NodeJS,npm
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
apt-get install -y nodejs
npm install -g npm@latest

# Install symbol-bootstrap
npm install -g symbol-bootstrap@"$SYMBOL_BOOTSTRAP_VER"

# Create user for symbol-platform Node
adduser --disabled-password --gecos "" "$USER"
echo "$USER:$PSWD" | chpasswd
usermod -aG docker "$USER"
usermod -aG sudo "$USER"

# ----------------------------------------------------------------------------------------------------

sudo -u $USER mkdir -p "$BOOTSTRAP_HOME"
cd "$BOOTSTRAP_HOME"

# Generate config and docker=compose.yml
if [ "$ASSEMBLY" = "peer" -o "$ASSEMBLY" = "dual" ]; then
  cat << __EOD__ >> $BOOTSTRAP_HOME/my-preset.yml
logLevel: error
nodes:
    -
        harvesting: true
        voting: false
        host: $HOST
        friendlyName: $FRIENDLY_NAME
        blockDisruptorSize: 8192
__EOD__
fi

if [ "$ASSEMBLY" = "api" -o "$ASSEMBLY" = "dual" ]; then
  cat << __EOD__ >> $BOOTSTRAP_HOME/my-preset.yml
throttlingBurst: 160
throttlingRate: 120
__EOD__
fi

symbol-bootstrap config --preset "$PRESET" --assembly "$ASSEMBLY" --customPreset=my-preset.yml --reset
symbol-bootstrap compose --user "$(id -u $USER):$(id -g $USER)"

# XXX: workaround for bug
#sed -i.bak '/set -e/d' $BOOTSTRAP_HOME/target/docker/mongo/mongors.sh

chown -R $USER: "$BOOTSTRAP_HOME"

if [ "$USE_HTTPS" = "on" ] && [ "$HOST" ]; then
  # Add https-portal container
  tee https-portal.part.yml << __EOD__
    https-portal:
        container_name: https-portal
        image: steveltn/https-portal:1
        ports:
            - "80:80"
            - "3001:443"
        volumes:
            - ./ssl-certs:/var/lib/https-portal
        environment:
            WEBSOCKET: 'true'
            STAGE: local
            DOMAINS: 'localhost -> http://rest-gateway:3000'
            # STAGE: production
            # DOMAINS: '$HOST -> http://rest-gateway:3000'
        depends_on:
            - rest-gateway
        restart: 'on-failure:2'
__EOD__
  sed -i -e "$(grep -n services: $BOOTSTRAP_HOME/target/docker/docker-compose.yml | cut -d: -f1)r https-portal.part.yml" $BOOTSTRAP_HOME/target/docker/docker-compose.yml
fi

# symbol-platform.service
tee /etc/systemd/system/symbol-platform.service << __EOD__
[Unit]
Description=Symbol Platform Service Daemon
After=docker.service
[Service]
Type=simple
User=$USER
Group=$USER
WorkingDirectory=$BOOTSTRAP_HOME
ExecStartPre=/usr/bin/symbol-bootstrap stop
ExecStartPre=-/bin/rm target/nodes/$ROLE-node/data/broker.lock
ExecStartPre=-/bin/rm target/nodes/$ROLE-node/data/broker.started
ExecStartPre=-/bin/rm target/nodes/$ROLE-node/data/recovery.lock
ExecStartPre=-/bin/rm target/nodes/$ROLE-node/data/server.lock
ExecStart=/usr/bin/symbol-bootstrap run
ExecStop=/usr/bin/symbol-bootstrap stop
TimeoutStartSec=180
TimeoutStopSec=120
Restart=on-failure
RestartSec=60
PrivateTmp=true
[Install]
WantedBy=default.target
__EOD__

# Enable symbol-platform service
systemctl daemon-reload
systemctl enable symbol-platform

# systemctl start symbol-platform

# ----------------------------------------------------------------------------------

# Configure sshd
# /bin/sed -i.bak -e "/^#Port/ s/.*/Port $SSHD_PORT/" /etc/ssh/sshd_config
# /bin/sed -i.bak -e "/^#AllowTcpForwarding/ s/.*/AllowTcpForwarding no/" /etc/ssh/sshd_config
# /bin/sed -i.bak -e "/^#GatewayPorts/ s/.*/GatewayPorts no/" /etc/ssh/sshd_config
# /bin/sed -i.bak -e "/^#PermitTunnel/ s/.*/PermitTunnel no/" /etc/ssh/sshd_config
# /bin/sed -i.bak -e "/^#PermitRootLogin/ s/.*/PermitRootLogin no/" /etc/ssh/sshd_config
# systemctl restart sshd

# Configure firewall
# ufw --force enable
# ufw default DENY
# ufw allow $SSHD_PORT
# ufw reload

# ----------------------------------------------------------------------------------

# # # Install Monit
# apt-get install -y monit
#
# cat << __EOD__ > /etc/monit/conf.d/symbol-platform
# # check system localhost
# #     group symbol-platform
# #     if loadavg (1min) > 5 then alert
# #     if loadavg (5min) > 3 then alert
# #     if cpu usage    > 95% for 15 cycles then alert
# #     if memory usage > 90% for 30 cycles then alert
# #     if swap usage   > 50% for 30 cycles then alert
# #
# # check device datafs with path /dev/vda1
# #     group symbol-platform
# #     if space usage > 70% for 5 times within 30 cycles then alert
# #     if space usage > 80% for 3 times within 15 cycles then alert
# #     if space usage > 95% then stop
#
# check host localhost with address localhost
#     group symbol-platform
#     start program = "/bin/systemctl start symbol-platform"
#     stop  program = "/bin/systemctl stop  symbol-platform"
#     if failed port 3000 protocol http
#         and request /node/health with content = '"apiNode":"up","db":"up"'
#         and within 1 cycles
#         then restart
#     if failed port 7900 within 1 cycles
#         then restart
#     if failed port 7902 within 1 cycles
#         then restart
# __EOD__
# systemctl restart monit

# # ----------------------------------------------------------------------------------
#
# # Install Fail2ban
# apt-get install -y fail2ban
# sed -i.bak -e "/^loglevel =/ s/.*/loglevel = NOTICE/" /etc/fail2ban/fail2ban.conf
# systemctl restart fail2ban
#
# # ----------------------------------------------------------------------------------

# Cleanup
apt-get clean -y && apt-get autoremove -y --purge
dpkg -l 'linux-image-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge
update-grub

# for vagrant
usermod -a -G docker vagrant
