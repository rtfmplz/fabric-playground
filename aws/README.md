# Build Hyperledger-Fabric Network on AWS with Terraform

> 본 실습은 AWS 상에 first-network를 구축하고, Org3를 추가하는 방법에 대해서 다룬다.
> first-network와add-org3는 각각 다른 AWS 계정에서 생성되는 것을 전제한다. (terraform file 구현에의해 같은 계정인 경우 AWS Service 간 이름 충돌이 발생할 수 있음)  

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
export TEST_CHAINCODE_NAME="mycc"
cd first-network
./bootstrap.sh
```

### output files for first-network

다음 파일은 Extra Org에 전달되어야 한다.

* tlsca.ordererorg-cert.pem
* public-load-balancer-dns-name.org1

다음 파일은 admin에 SSH 접근을 위해서 사용한다.

* admin-ec2-public-ip.org1

## STEP 2. Org3-Network Bootstrap

> `tlsca.ordererorg-cert.pem`, `public-load-balancer-dns-name.org1` 및 `add-org3` 폴더는 안전한 채널을 통해 Fabric-network에 참여하고자하는 조직에 전달되어야 하지만, 본 실습에서는 다음과 같이 폴더에 복사하는 것으로 갈음한다.

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
export TEST_CHANNEL_NAME="ch1"
export TEST_CHAINCODE_NAME="mycc"
cd add-org3
./bootstrap.sh
```

### output files for add-org3

다음 파일들은 HOST Org에 전달되어야 한다.

* channel-artifact.json
* public-load-balaancer-dns-name.org3

다음 파일은 admin에 SSH 접근을 위해서 사용한다.

* admin-ec2-public-ip.org3

## STEP 3. Add Org3 to First-Network

> `channel-artifact.json`, `public-load-balaancer-dns-name.org3`는 안전한 채널을 통해 HOST 조직에 전달되어야 하지만, 본 실습에서는 다음과 같이 폴더에 복사하는 것으로 갈음한다.

STEP 2에서 생성된 `channel-artifact.json`을 `first-network/add-org3/` 경로 아래에 복사 한 후 다음 명령을 수행해서 `org3.example.com`을 fabric-network에 포함시킨다.
`admin-ec2-public-ip.org1`의 값으로 `first-network/add-org3/terraform.tfvars`의 `admin_ec2_public_ip`값을 업데이트 한다.

```bash
./add-org.sh
```

## STEP 4. Join test-channel

channel-join script 실행 후, chaincode install  
ADMIN_EC2_PUBLIC_IP 값은 STEP 1에서 생성된 `admin-ec2-public-ip.org3`의 내용으로 업데이트 한다.

```bash
export ADMIN_EC2_PUBLIC_IP="13.209.13.255"
ssh -i ~/.ssh/id_rsa ec2-user@${ADMIN_EC2_PUBLIC_IP}
docker exec -it cli bash
peer channel fetch 0 $TEST_CHANNEL_NAME.block -o orderer0.ordererorg:7050 -c $TEST_CHANNEL_NAME --tls --cafile $ORDERER_ORG_TLSCACERTS
peer channel join -b $TEST_CHANNEL_NAME.block
peer chaincode install -n ${TEST_CHAINCODE_NAME} -v 1.0 -p github.com/chaincode/chaincode_example02/go/
peer chaincode query -C ${TEST_CHANNEL_NAME} -n ${TEST_CHAINCODE_NAME} -c '{"Args":["query","a"]}'
```

### STEP 5. Verification

정상적으로 두 조직이 연결되었는지 확인하기 위해서 `org1.example.com`에서 chaincode invoke를 한 후, `org3.example.com`에서 값의 변화를 확인해 본다.

> `org3.example.com`의 public-load-balancer-dns-name을 `org1.example.com`의 nginx

```bash
peer chaincode invoke -o orderer0.ordererorg:7050 --tls true --cafile $ORDERER_ORG_TLSCACERTS -C ch1 -n mycc -c '{"Args":["invoke","a","b","10"]}'
```

## Appendix 1. Terraform 관련 추가

### graph

> dot 명령어가 없는 경우 아래의 명령으로 설치한다.
>
> * `brew install graphviz`

```bash
# https://www.terraform.io/docs/commands/graph.html
terraform graph | dot -Tsvg > graph.svg
```

#### blastradius

graph를 이쁘게 보여주는 도구

* [blast-radius](https://github.com/28mm/blast-radius)

```bash
pip install blastradius
blast-radius --serve /path/to/terraform/directory
```

### 기타 명령

* `terraform fmt`
* `terraform console`
