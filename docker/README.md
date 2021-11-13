# ansible

## イメージビルド

```shell
$ docker build -t ansible docker/ansible
```

## 実行例

```shell
$ docker run --rm -v $(pwd)/playbook:/playbook ansible -i hosts setup.yml --limit remote
```
