# Join to HLF network in On-Premise with new organization

## Prerequisite

### AWS ACCESS Key 발급

[AWS IAM 사용자의 액세스 키 발급 및 관리](https://www.44bits.io/ko/post/publishing_and_managing_aws_user_access_key) 참조하여 키를 발급 한 후, 아래 명령을 통해서 환경변수로 등록

```bash
export AWS_ACCESS_KEY_ID="ASDFASDFASDFASDFASDF"
export AWS_SECRET_ACCESS_KEY="asdfasdfasdfasdfasdfasdfasdfasdfasdfasdf"
```

### EC2에 ssh 접속을 위한 RSA KEY PAIR 생성

```bash
export EMAIL="kjlee.ko@gmail.com"
ssh-keygen -t rsa -b 4096 -C $EMAIL -f "$HOME/.ssh/id_rsa" -N ""
```

### Create Crypto Materials

`./resources/hyperledger-fabric/crypto.yaml` 파일의 `Name`, `Domain` 을 적절하게 수정한 후 아래 명령을 통해 조직에서 사용할 Crypto Materials를 만든다.

```bash
cd resources/hyperledger-fabric
cryptogen generate --config=crypto.yaml --output=crypto
```

## plan, apply and destroy

```bash
terraform paln
```

```bash
terraform apply
```

```bash
terraform destroy
```

## graph

> dot 명령어가 없는 경우 아래의 명령으로 설치한다.
>
> * `brew install graphviz`

```bash
# https://www.terraform.io/docs/commands/graph.html
terraform graph | dot -Tsvg > graph.svg
```

### blastradius

graph를 이쁘게 보여주는 도구

* [blast-radius](https://github.com/28mm/blast-radius)

```bash
pip install blastradius
blast-radius --serve /path/to/terraform/directory
```

## 기타 명령

* `terraform fmt`
* `terraform console`
