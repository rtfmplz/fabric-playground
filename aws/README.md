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
export TEST_CHAINCODE_NAME="ch1"
cd first-network
./bootstrap.sh
```

### output files for first-network

> 해당 파일들은 Extra Org에 전달되어야 한다.

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

> 해당 파일들은 HOST Org에 전달되어야 한다.

* channel-artifact.json
* public-load-balaancer-dns-name.org3

## STEP 3. Add Org3 to First-Network

`channel-artifact.json`을 admin instance 의 /tmp 경로에 복사 한 후, cli docker container를 이용해서 add-org script 실행

```bash
export CHANNEL_NAME="ch1"
export ADMIN_EC2_PUBLIC_IP="52.78.209.246"
scp -i ~/.ssh/id_rsa ./artifacts/channel-artifact.json ec2-user@${ADMIN_EC2_PUBLIC_IP}:/tmp
ssh -i ~/.ssh/id_rsa ec2-user@${ADMIN_EC2_PUBLIC_IP}
docker exec -it cli bash
export CHANNEL_NAME="ch1"
peer channel fetch config config_block.pb -o orderer0.ordererorg:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_ORG_TLSCACERTS
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' ./config.json ./channel-artifact.json > ./modified_config.json
configtxlator proto_encode --input ./config.json --type common.Config >original_config.pb
configtxlator proto_encode --input ./modified_config.json --type common.Config >modified_config.pb
configtxlator compute_update --channel_id "${CHANNEL_NAME}" --original original_config.pb --updated modified_config.pb >config_update.pb
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate >config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope >org3_update_in_envelope.pb
peer channel signconfigtx -f "org3_update_in_envelope.pb"
peer channel update -f org3_update_in_envelope.pb -c $CHANNEL_NAME -o orderer0.ordererorg:7050 --tls --cafile $ORDERER_ORG_TLSCACERTS
```

## STEP 4. Join test-channel

channel-join script 실행 후, chaincode install

```bash
docker exec -it cli bash
export CHANNEL_NAME="ch1"
echo "${gw0-private_ip} orderer0.ordererorg" >> /etc/hosts
peer channel fetch 0 $CHANNEL_NAME.block -o orderer0.ordererorg:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_ORG_TLSCACERTS
peer channel join -b $CHANNEL_NAME.block
```

```bash
peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/
peer chaincode query -C ch1 -n mycc -c '{"Args":["query","a"]}'
```
