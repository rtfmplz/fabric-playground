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
ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
```

### Commands

bootstrap.sh 및 기타 스크립트 실행을 위해서 docker, Hyperledger-Fabric CLI 명령과 기타 Unix Command가 필요하다.

#### Docker

Docker for Desktop 을 자신의 운영체제에 알맞은 것으로 설치한다.

#### Export Hyperledger-fabric Tools

```bash
export PROJECT_ROOT=$PWD
export PATH=$PATH:$PROJECT_ROOT/hlf-tools
```

#### Install Commands

```bash
brew install tree
brew install terraform
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

네트워크가 AWS 상에 모두 구성되면 cli(fabric-tools)를 통해서 Channel을 생성하고 chaincode를 설치한다.

```bash
cd cli-tools
docker-compose up -d
docker exec -it cli.org1.example.com sh -c "./create_channel.sh"
docker exec -it cli.org1.example.com sh -c "./install_chaincode.sh"
```

chaincode가 정상적으로 동작하는지 아래 명령으로 확인해 본다.

```bash
[FIXME] script 로 만들기
docker exec -it cli.org1.example.com sh -c "peer chaincode invoke -o orderer0.ordererorg:57050 --tls true --cafile ${ORDERER_ORG_TLSCACERTS} -C ${TEST_CHANNEL_NAME} -n ${TEST_CHAINCODE_NAME} -c '{\"Args\":[\"invoke\",\"a\",\"b\",\"10\"]}'"
docker exec -it cli.org1.example.com sh -c "peer chaincode query -C ${TEST_CHANNEL_NAME} -n ${TEST_CHAINCODE_NAME} -c '{\"Args\":[\"query\",\"a\"]}'"
```

### output files for first-network

다음 파일은 Extra Org에 전달되어야 한다.

* tlsca.ordererorg-cert.pem
* public-load-balancer-dns-name.org1

## STEP 2. Org3-Network Bootstrap

> `tlsca.ordererorg-cert.pem`, `public-load-balancer-dns-name.org1` 및 `add-org3` 폴더는 안전한 채널을 통해 Fabric-network에 참여하고자하는 조직에 전달되어야 하지만, 본 실습에서는 다음과 같이 폴더에 복사하는 것으로 갈음한다.

STEP 1에서 생성된 `tlsca.ordererorg-cert.pem`, `public-load-balancer-dns-name.org1`을 add-org3 폴더 아래 위치 시킨 후, bootstrpa.sh 실행

```bash
export AWS_ACCESS_KEY_ID="QWERQWERQWERQWERQWER"
export AWS_SECRET_ACCESS_KEY="qwerqwerqwerqwerqwerqwerqwerqwerqwerqwer"
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
* public-load-balaancer-dns-name.org3 (여기서는 쓰이지 않지만, org간 gossip 통신을 위해서 방화벽을 열기 위해 쓰일 수 있다.)

## STEP 3. Add Org3 to First-Network

> `channel-artifact.json`, `public-load-balaancer-dns-name.org3`는 안전한 채널을 통해 HOST 조직에 전달되어야 하지만, 본 실습에서는 다음과 같이 폴더에 복사하는 것으로 갈음한다.  

STEP 2에서 생성된 `channel-artifact.json`을 `first-network/cli-tools/` 경로 아래에 복사 한 후 `add-org3.sh` 실행해서 `org3.example.com`을 fabric-network에 포함시킨다.

```bash
cd cli-tools
docker-compose up -d
docker exec -it cli.org1.example.com sh -c "./add-org3.sh"
```

## STEP 4. Join test-channel & chaincode install  

STEP 3에 의해서 조직이 추가되고, 방화벽도 열리면 `join-channel.sh` 스크립트를 실행한다.

```bash
cd cli-tools
docker-compose up -d
docker exec -it cli.org3.example.com sh -c "./join-channel.sh"
```

### STEP 5. Verification

```bash
docker exec -it cli.org1.example.com sh -c "peer chaincode invoke -o orderer0.ordererorg:57050 --tls true --cafile ${ORDERER_ORG_TLSCACERTS} -C ${TEST_CHANNEL_NAME} -n ${TEST_CHAINCODE_NAME} -c '{\"Args\":[\"invoke\",\"a\",\"b\",\"10\"]}'"
docker exec -it cli.org1.example.com sh -c "peer chaincode query -C ${TEST_CHANNEL_NAME} -n ${TEST_CHAINCODE_NAME} -c '{\"Args\":[\"query\",\"a\"]}'"
docker exec -it cli.org3.example.com sh -c "peer chaincode invoke -o orderer0.ordererorg:57050 --tls true --cafile ${ORDERER_ORG_TLSCACERTS} -C ${TEST_CHANNEL_NAME} -n ${TEST_CHAINCODE_NAME} -c '{\"Args\":[\"invoke\",\"a\",\"b\",\"10\"]}'"
docker exec -it cli.org3.example.com sh -c "peer chaincode query -C ${TEST_CHANNEL_NAME} -n ${TEST_CHAINCODE_NAME} -c '{\"Args\":[\"query\",\"a\"]}'"
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
