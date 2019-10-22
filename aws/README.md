# Build Hyperledger-Fabric Network on AWS with Terraform

> 본 실습은 AWS 상에 first-network를 구축하고, Org3를 추가하는 방법에 대해서 다룬다.
> first-network와add-org3는 각각 다른 AWS 계정에서 생성되는 것을 전제한다. (terraform file 구현에의해 같은 계정인 경우 AWS Service 간 이름 충돌이 발생할 수 있음)  

## Prerequisite

### EC2에 ssh 접속을 위한 RSA KEY PAIR 생성

```bash
export EMAIL="kjlee.ko@gmail.com"
ssh-keygen -t rsa -b 4096 -C $EMAIL -f "$HOME/.ssh/id_rsa" -N ""
```

## STEP 1. First-Network Bootstrap

다음 환경변수 추가 후, bootstrpa.sh 실행 한다.

```bash
export AWS_ACCESS_KEY_ID="ASDFASDFASDFASDFASDF"
export AWS_SECRET_ACCESS_KEY="asdfasdfasdfasdfasdfasdfasdfasdfasdfasdf"
export ORG_NAME="Org1"
export ORG_DOMAIN="org1.example.com"
export ORDERER_ORG_NAME="OrdererOrg"
export ORDERER_ORG_DOMAIN="ordererorg"
export TEST_CHANNEL_NAME="ch1"
cd first-network
./bootstrap.sh
```

### output files for first-network

* tlsca.ordererorg-cert.pem
* public-load-balancer-dns-name.org1

## STEP 2. Org3-Network Bootstrap

STEP 1에서 생성된 `tlsca.ordererorg-cert.pem`을 add-org3 폴더 아래 위치 시킨다.
그리고, `public-load-balancer-dns-name.org1`안의 dns-name을 포함한 기타 환경변수를 export 한 후, bootstrpa.sh 실행

```bash
export AWS_ACCESS_KEY_ID="QWERQWERQWERQWERQWER"
export AWS_SECRET_ACCESS_KEY="qwerqwerqwerqwerqwerqwerqwerqwerqwerqwer"
export HOST_ENDPOINT_DNS_NAME="public-load-balancer-1d57da046f9a3e68.elb.ap-northeast-2.amazonaws.com"
export ORG_NAME="Org3"
export ORG_DOMAIN="org3.example.com"
export HOST_ORG_DOMAIN="org1.example.com"
export ORDERER_ORG_DOMAIN="ordererorg"
cd add-org3
./bootstrap.sh
```

### output files for add-org3

* channel-artifact.json
* public-load-balaancer-dns-name.org3
