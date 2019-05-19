# README

## Precondition

본 문서는 Hyperledger-Fabric 1.3 을 기반으로 동작하므로 아래 스크립트를 이용해서 관련 tool, docker image 등을 다운로드 한다.

```bash
curl -sSL http://bit.ly/2ysbOFE | bash -s 1.3.0
```

## BootStrap Fabric Network

1. Create MSP using cryptogen

```bash
cryptogen generate --config=crypto-config.yaml --output=crypto
```

2. Create genesis.block

```bash
configtxgen -profile OrgsOrdererGenesis -outputBlock genesis.block
```

3. Create Channel Transaction

```bash
configtxgen -profile OrgsChannel -outputCreateChannelTx ch1.tx -channelID ch1
```

4. Create channel transaction for update Org1 anchor peer

```bash
configtxgen -profile OrgsChannel -outputAnchorPeersUpdate updateAnchorOrg1.tx -channelID ch1 -asOrg Org1
```

5. BootStrap Fabric network using docker-compose

```bash
docker stop $(docker ps -aq) || docker rm $(docker ps -aq) || docker-compose -f bootstrap.yaml up -d
```

## Attach Fabric-CA

> [주의] Fabcar dapp을 정상 구동하려면 채널 생성 전에 Fabric-ca를 실행해야 한다.

1. Update fabric-ca.yaml

> 아래 tree 명령 실행해서 출력되는 sk 파일의 이름을 ./base/fabric-ca.yaml 파일의 FABRIC_CA_SERVER_CA_KEYFILE 에 설정한다.

```
tree crypto/peerOrganizations/org1/ca
crypto/peerOrganizations/org1/ca
├── 0e47f93b7ae251a8f1613b003362ef828901959642aa004bbbc4ab719eab1be7_sk
└── ca.org1-cert.pem
```

1. Run Fabric-CA container

```
docker-compose -f ./base/fabric-ca.yaml up -d
```

## Create, join channel & update Anchor peer

1. Create, join channel & update Anchor peer

```bash
docker exec -it cli /bin/bash
```

```bash
# w/ TLS
peer channel create -o orderer1.ordererorg:7050 -c ch1 -f ch1.tx
# w/o TLS
peer channel create -o orderer1.ordererorg:7050 -c ch1 -f ch1.tx --tls --cafile $ORDERER_ORG_TLSCACERTS
```

```bash
peer channel join -b ch1.block
```

```bash
# w/ TLS
peer channel update -o orderer1.ordererorg:7050 -c ch1 -f ./updateAnchorOrg1.tx
# w/o TLS
peer channel update -o orderer1.ordererorg:7050 -c ch1 -f ./updateAnchorOrg1.tx --tls --cafile $ORDERER_ORG_TLSCACERTS
```

## Example02

7. install chiancode

```bash
peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/
```

8. instantiate chaincode

```bash
# w/ TLS
peer chaincode instantiate -o orderer1.ordererorg:7050 -C ch1 -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member')"
# w/o TLS
peer chaincode instantiate -o orderer1.ordererorg:7050 --tls --cafile $ORDERER_ORG_TLSCACERTS -C ch1 -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member')"
```

```bash
peer chaincode query -C ch1 -n mycc -c '{"Args":["query","a"]}'
```

9. invoke chaincode

```bash
# w/ TLS
peer chaincode invoke -o orderer1.ordererorg:7050 -C ch1 -n mycc --peerAddresses peer1.org1:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1/peers/peer1.org1/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}'
# w/o TLS
peer chaincode invoke -o orderer1.ordererorg:7050 --tls true --cafile $ORDERER_ORG_TLSCACERTS -C ch1 -n mycc --peerAddresses peer1.org1:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1/peers/peer1.org1/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}'
```

10. confirm result

```bash
peer chaincode query -C ch1 -n mycc -c '{"Args":["query","a"]}'
```

> CouchDB
>
> * [couchdb1](http://localhost:5984/_utils/)

## Fabcar

> Fabcar 예제가 Fabric-CA 를 통해서 register, enroll 하는 과정을 담고 있기때문에 예제로 사용

1. install & instantiate & invoke Fabcar

```bash
docker exec -it cli /bin/bash
```

```bash
peer chaincode install -n fabcar -v 1.0 -p github.com/chaincode/fabcar/go/
```

```bash
# w/ TLS
peer chaincode instantiate -o orderer1.ordererorg:7050 -C ch1 -n fabcar -v 1.0 -c '{"Args":[""]}' -P "OR ('Org1MSP.member')"
# w/o TLS
peer chaincode instantiate -o orderer1.ordererorg:7050 -C ch1 -n fabcar -v 1.0 -c '{"Args":[""]}' -P "OR ('Org1MSP.member')" --tls --cafile $ORDERER_ORG_TLSCACERTS
```

```bash
# w/ TLS
peer chaincode invoke -o orderer1.ordererorg:7050 -C ch1 -n fabcar -c '{"function":"initLedger","Args":[""]}'
# w/o TLS
peer chaincode invoke -o orderer1.ordererorg:7050 -C ch1 -n fabcar -c '{"function":"initLedger","Args":[""]}' --tls --cafile $ORDERER_ORG_TLSCACERTS
```

```bash
peer chaincode query -C ch1 -n fabcar -c '{"Args":["queryAllCars"]}'
peer chaincode query -C ch1 -n fabcar -c '{"Args":["queryCar", "CAR4"]}'
```

2. invoke & query w/ fabcar dapp

> fabcar 폴더에서 진행

```bash
npm install npm@5.6.0 -g
npm install
```

3. register & enroll

```bash
node enrollAdmin.js
```

```bash
node registerUser.js
```

4. query & invoke

```bash
node query.js
```

```bash
node invoke.js
```

## Blockchain Explorer

1. clean docker volume

```bash
docker volume rm *_credentialstore *_pgdata
```

2. clone blockchain explorer

```bash
git clone https://github.com/hyperledger/blockchain-explorer.git
```

3. copy files for blockchain explorer

```bash
cp -avR explorer/ ${blockchain-explorer-pwd}
```

4. docker-compose up

```bash
docker stop explorer explorerdb || docker rm explorer explorerdb
docker-compose -f explorer.yaml up -d
```