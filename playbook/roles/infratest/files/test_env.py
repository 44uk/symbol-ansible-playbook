def test_passwd_file(host):
    passwd = host.file('/etc/passwd')
    assert passwd.contains('root')
    assert passwd.user  == 'root'
    assert passwd.group == 'root'
    assert passwd.mode  == 0o644

def test_swapfile(host):
    swapfile = host.file('/var/swapfile')
    assert swapfile.user  == 'root'
    assert swapfile.group == 'root'
    assert swapfile.mode  == 0o600

def test_nodejs_is_installed(host):
    nodejs = host.package('nodejs')
    assert nodejs.is_installed
    assert nodejs.version.startswith('16')

def test_docker_is_installed(host):
    docker = host.package('docker-ce')
    assert docker.is_installed
    assert '20.10' in docker.version

def test_docker_running_and_enabled(host):
    docker = host.service('docker')
    assert docker.is_enabled
    assert docker.is_running

def test_docker_compose_is_installed(host):
    assert host.exists('docker-compose')

def test_symbol_bootstrap_is_installed(host):
    assert host.exists('symbol-bootstrap')

def test_symbol_cli_is_installed(host):
    assert host.exists('symbol-cli')

# def test_monit_is_installed(host):
#     monit = host.package('monit')
#     assert monit.is_installed

# def test_monit_running_and_enabled(host):
#     monit = host.service('monit')
#     assert monit.is_enabled
#     assert monit.is_running

# def test_fail2ban_is_installed(host):
#     fail2ban = host.package('fail2ban')
#     assert fail2ban.is_installed

# def test_fail2ban_running_and_enabled(host):
#     fail2ban = host.service('fail2ban')
#     assert fail2ban.is_enabled
#     assert fail2ban.is_running

# def test_symbol_platform_running_and_enabled(host):
#     symbol_platform = host.service('symbol-platform')
#     assert symbol_platform.is_enabled
#     assert symbol_platform.is_running
