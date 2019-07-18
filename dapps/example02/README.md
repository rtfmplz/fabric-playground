# Example02 Dapp

> Example02 Dapp은 Fabric-CA 를 통해서 register, enroll 하는 과정을 담고있기 때문에 Fabric-CA가 구동중인지 확인한다.
>
> * [Attach Fabric-CA at Fabric-Playground](https://github.com/rtfmplz/fabric-playground/blob/master/README.md#attach-fabric-ca)

## Chaincode install & instantiate & invoke

```bash
docker exec -it cli /bin/bash
```

```bash
peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/
```

```bash
# w/o TLS
peer chaincode instantiate -o orderer1.ordererorg:7050 -C ch1 -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member')"
# w/ TLS
peer chaincode instantiate -o orderer1.ordererorg:7050 --tls --cafile $ORDERER_ORG_TLSCACERTS -C ch1 -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member')"
```

```bash
peer chaincode query -C ch1 -n mycc -c '{"Args":["query","a"]}'
```

```bash
# w/o TLS
peer chaincode invoke -o orderer1.ordererorg:7050 -C ch1 -n mycc --peerAddresses peer1.org1:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1/peers/peer1.org1/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}'
# w/ TLS
peer chaincode invoke -o orderer1.ordererorg:7050 --tls true --cafile $ORDERER_ORG_TLSCACERTS -C ch1 -n mycc --peerAddresses peer1.org1:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1/peers/peer1.org1/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}'
```

```bash
peer chaincode query -C ch1 -n mycc -c '{"Args":["query","a"]}'
```

## Chaincode invoke & query using Example02 dapp

> Example02 dapp은 아래 node.js 버전에서 동작한다.
>
> * v8.9.0 or higher, up to 9.0 ( Node v9.0+ is not supported )

* install pacakge

```bash
nvm use lts/carbon
npm install
```

* register & enroll

```bash
node enrollAdmin.js
```

```bash
node registerUser.js
```

* query & invoke

```bash
node query.js
```

```bash
node invoke.js
```
