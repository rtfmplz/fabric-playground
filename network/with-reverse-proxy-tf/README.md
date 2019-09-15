# Bringing Hyperledger-Fabric Organization up on AWS using Terraform

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
