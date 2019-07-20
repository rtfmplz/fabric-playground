# README

## Precondition

```bash
docker network create fabric-minimal
```

## BootStrap Fabric Network

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

* BootStrap Fabric network using docker-compose

```bash
docker stop $(docker ps -aq) && docker rm $(docker ps -aq) && rm -rf ./production
docker rmi $(docker images | grep dev)
docker-compose up -d
```

> ### 참고: none(untaggged) image를 지우고 싶다면?
>
> * docker rmi $(docker images -f "dangling=true" -q)

## Attach Fabric-CA

> [주의] Fabcar dapp을 정상 구동하려면 채널 생성 전에 Fabric-ca를 실행해야 한다.

* Update fabric-ca.yaml

> 아래 tree 명령 실행해서 출력되는 sk 파일의 이름을 ./docker-compose/fabric-ca.yaml 파일의 FABRIC_CA_SERVER_CA_KEYFILE 에 설

정한다.

tree crypto/peerOrganizations/org1/ca

```bash
tree crypto/peerOrganizations/org1/ca
├── 0e47f93b7ae251a8f1613b003362ef828901959642aa004bbbc4ab719eab1be7_sk
└── ca.org1-cert.pem
```

* Run Fabric-CA container

```bash
docker-compose -f ./docker-compose/fabric-ca.yaml up -d
```

## Create, join channel & update Anchor peer

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

## Example02 for test

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

> CouchDB
>
> * [couchdb1](http://localhost:5984/_utils/)

## peer2.org1

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
