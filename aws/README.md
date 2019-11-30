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

### Install or Exports Commands

bootstrap.sh 스크립트 실행을 위해서 다음 Hyperledger-Fabric CLI 명령과 기타 Unix Command가 필요하다.

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
export HOST_ENDPOINT_DNS_NAME="public-load-balancer-4d490c0338a4abcf.elb.ap-northeast-2.amazonaws.com"
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

STEP 2에서 생성된 `channel-artifact.json`을 `first-network/add-org3/` 경로 아래에 복사 한 후 `add-org3.sh` 실행해서 `org3.example.com`을 fabric-network에 포함시킨다.
`admin-ec2-public-ip.org1`의 값을 인자로 `add-org3.sh` 스크립트를 실행한다.

```bash
cp $PROJECT_ROOT/add-org3/artifacts/channel-artifact.json $PROJECT_ROOT/first-network/add-org3/
./add-org3.sh "0.0.0.0"
```

다음으로 `public-load-balaancer-dns-name.org3`를 이용해서 nginx.conf를 업데이트하고 nginx를 재실행 해준다.

```bash
# [TODO] Org1 -> Org3로 outbound를 열어주고, `Peer`, `Orderer`가 Org3 Endpoint 주소를 알 수 있도록 하는 Script 작성
```

> [TODO] Org1으로의 inbound가 열려 있기 때문에 Org3 -> Org1으로의 query는 가능하지만, invoke는 정상적으로 동작하지 않는다.
> invoke에 대한 response는 `Chaincode invoke successful. result: status:200`을 받지만 실제로 Orderer의 log를 살펴보면 다음과 같은 에러가 발생한다.
>
> ```bash
> # 10.0.201.239는 public-subnet에 속한 ec2의 private-ip
> [orderer.common.broadcast] Handle -> WARN 042 Error reading from 10.0.201.239:33666: rpc error: code = Canceled desc = context canceled
> [comm.grpc.server] 1 -> INFO 043 streaming call completed grpc.service=orderer.AtomicBroadcast grpc.method=Broadcast grpc.peer_address=10.0.201.239:33666 error="rpc error: code = Canceled desc = context canceled" grpc.code=Canceled grpc.call_duration=20.005644ms
> ```

## STEP 4. Join test-channel & chaincode install  

STEP 3에 의해서 조직이 추가되고, 방화벽도 열리면 `admin-ec2-public-ip.org3`의 값을 인자로 `join-channel.sh` 스크립트를 실행한다.

```bash
./join-channel.sh "0.0.0.0"
```

### STEP 5. Verification

정상적으로 두 조직이 연결되었는지 확인하기 위해서 `org1.example.com`에서 chaincode invoke를 한 후, `org3.example.com`에서 값의 변화를 확인해 본다.  
`org1.example.com`와 `org3.example.com`의 admin instance 에 접속 후, cli docker container에 들어가서 chaincode invoke와 query를 해보면 값이 반영됨을 확인 할 수 있다.

```bash
# ssh -i ~/.ssh/id_rsa ec2-user@0.0.0.0
docker exec -it cli /bin/bash
peer chaincode invoke -o orderer0.ordererorg:7050 --tls true --cafile $ORDERER_ORG_TLSCACERTS -C ch1 -n mycc -c '{"Args":["invoke","a","b","10"]}'
peer chaincode query -C ${TEST_CHANNEL_NAME} -n ${TEST_CHAINCODE_NAME} -c '{"Args":["query","a"]}'
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
