# setup HTTPS

## Prerequisite

### Domain

1. サーバのIPアドレスを確認
2. AレコードでIPアドレスとドメインを紐付ける
3. digコマンドで疎通を確認しておく


### Host vars

Create and Edit `playbook/host_vars/{INVENTORY_HOSTNAME}.yml`.

See `playbook/host_vars/sample.yml` for example.

```yaml
# Used if not `certbot_certs[].email``
certbot_admin_email: __your_email__@example.com
certbot_certs:
  - email: __your_email__@example.com # (Optional)
    domains:
      - your_owned_fqdn.example.com
```


## Run playbook

```shell
$ make remote-https
```
