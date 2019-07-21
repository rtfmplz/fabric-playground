# Minimal Network

다음의 Docker Container 구성으로 Hypledger-Fabric Network를 구성한다.

* 1 cli (fabric-tools)
* 1 fabric-ca
* 1 orderer in Ordererorg
* 1 kafak
* 1 zookeeper
* 2 peer in Org1
* 2 couchdb for each peer

## Prerequisites

> 본 Minimal Network는 `cryptogen`, `configtxgen` 을 이용해서 구축된다.

### Create Hyperledger Fabric Materials

* Create MSP using cryptogen

```bash
cryptogen generate --config=crypto-config.yaml --output=crypto
```

* Create genesis.block

```bash
configtxgen -profile OrgsOrdererGenesis -outputBlock genesis.block
```

* Create Channel Transaction

```bash
configtxgen -profile OrgsChannel -outputCreateChannelTx ch1.tx -channelID ch1
```

* Create channel transaction for update Org1 anchor peer

```bash
configtxgen -profile OrgsChannel -outputAnchorPeersUpdate updateAnchorOrg1.tx -channelID ch1 -asOrg Org1
```

### Clean Environment

* Docker stop, rm, rmi

```bash
docker stop $(docker ps -aq) && docker rm $(docker ps -aq) && rm -rf ./production
docker rmi $(docker images | grep dev)
```

> [참고] none(untaggged) image를 지우고 싶다면?
>
> * docker rmi $(docker images -f "dangling=true" -q)

### Docker Network

```bash
docker network create fabric-minimal
```

## BootStrap Fabric Network

### Update FABRIC_CA_SERVER_CA_KEYFILE for Fabric-CA

> [주의] Fabric-ca는 채널 생성 전에 구동되어야 한다.

아래 tree 명령을 실행해서 출력되는 sk 파일명으로 docker-compose.yaml 파일의 `FABRIC_CA_SERVER_CA_KEYFILE`를 업데이트 한다.

```bash
tree crypto/peerOrganizations/org1/ca

crypto/peerOrganizations/org1/ca
├── 0e47f93b7ae251a8f1613b003362ef828901959642aa004bbbc4ab719eab1be7_sk
└── ca.org1-cert.pem
```

### BootStrap Fabric network using docker-compose

```bash
docker-compose up -d
```

## Create, join channel & update Anchor peer

> [주의] w/ TLS 명령을 사용하는 경우 cli, peer, orderer의 tls enable 관련 설정을 true로 해 주어야 한다.

```bash
docker exec -it cli /bin/bash
```

```bash
# w/o TLS
peer channel create -o orderer1.ordererorg:7050 -c ch1 -f ch1.tx
# w/ TLS
peer channel create -o orderer1.ordererorg:7050 -c ch1 -f ch1.tx --tls --cafile $ORDERER_ORG_TLSCACERTS
```

```bash
peer channel join -b ch1.block
```

```bash
# w/o TLS
peer channel update -o orderer1.ordererorg:7050 -c ch1 -f ./updateAnchorOrg1.tx
# w/ TLS
peer channel update -o orderer1.ordererorg:7050 -c ch1 -f ./updateAnchorOrg1.tx --tls --cafile $ORDERER_ORG_TLSCACERTS
```

## Test Example02

Network가 정상적으로 동작하는지 확인하기 위해서 chaincode_example02를 install, instantiate하고 간단한 invoke, query를 실행해 본다.

* install chiancode

```bash
peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/
```

* instantiate chaincode

```bash
# w/o TLS
peer chaincode instantiate -o orderer1.ordererorg:7050 -C ch1 -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member')"
# w/ TLS
peer chaincode instantiate -o orderer1.ordererorg:7050 --tls --cafile $ORDERER_ORG_TLSCACERTS -C ch1 -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member')"
```

```bash
peer chaincode query -C ch1 -n mycc -c '{"Args":["query","a"]}'
```

* invoke chaincode

```bash
# w/o TLS
peer chaincode invoke -o orderer1.ordererorg:7050 -C ch1 -n mycc --peerAddresses peer1.org1:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1/peers/peer1.org1/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}'
# w/ TLS
peer chaincode invoke -o orderer1.ordererorg:7050 --tls true --cafile $ORDERER_ORG_TLSCACERTS -C ch1 -n mycc --peerAddresses peer1.org1:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1/peers/peer1.org1/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}'
```

* confirm result

```bash
peer chaincode query -C ch1 -n mycc -c '{"Args":["query","a"]}'
```

> CouchDB for Peer1
>
> * [couchdb1](http://localhost:5984/_utils/)

## Join peer2.org1 to ch1 & install chaincode

여기까지 진행하면 peer2.org1의 WorldState([couchdb2](http://localhost:6984/_utils/)) 에는 데이터가 없는 것을 확인 할 수 있다.

peer2가 ch1에 join 되지 않았기 때문이다.

```bash
CORE_PEER_ADDRESS=peer2.org1:7051 peer channel list
```

peer2를 channel(ch1)에 join 시키면 Block이 복제되고, 데이터를 확인 할 수 있다.

```bash
CORE_PEER_ADDRESS=peer2.org1:7051 peer channel join -b ch1.block
```

Install chaincode

```bash
CORE_PEER_ADDRESS=peer2.org1:7051 peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/
```

Block이 복제되면 qeury가 가능하다.

```bash
CORE_PEER_ADDRESS=peer2.org1:7051 peer chaincode query -C ch1 -n mycc -c '{"Args":["query","a"]}'
```
