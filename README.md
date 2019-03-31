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
docker stop $(docker ps -aq) && docker rm $(docker ps -aq) && docker-compose -f bootstrap.yaml up -d
```

6. Create, join channel & update Anchor peer

```bash
docker exec -it cli /bin/bash
```

```bash
peer channel create -o orderer1.ordererorg:7050 -c ch1 -f ch1.tx --tls --cafile $ORDERER_ORG_TLSCACERTS
```

```bash
peer channel join -b ch1.block
```

```bash
peer channel update -o orderer1.ordererorg:7050 -c ch1 -f ./updateAnchorOrg1.tx --tls --cafile $ORDERER_ORG_TLSCACERTS
```

7. install chiancode

```bash
peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/
```

8. instantiate chaincode

```bash
peer chaincode instantiate -o orderer1.ordererorg:7050 --tls --cafile $ORDERER_ORG_TLSCACERTS -C ch1 -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member')"
```

```bash
peer chaincode query -C ch1 -n mycc -c '{"Args":["query","a"]}'
```

9. invoke chaincode

```bash
peer chaincode invoke -o orderer1.ordererorg:7050 --tls true --cafile $ORDERER_ORG_TLSCACERTS -C ch1 -n mycc --peerAddresses peer1.org1:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1/peers/peer1.org1/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}'
```

10. confirm result

```bash
peer chaincode query -C ch1 -n mycc -c '{"Args":["query","a"]}'
```

Or 

* [couchdb1](http://localhost:5984/_utils/)