# Private Data Collection Example

> hyperledger-fabric network 는 미리 구동시켜 놓자, 아래 참조
>
> * [BootStrap Fabric Network](https://github.com/rtfmplz/fabric-playground#bootstrap-fabric-network)
> * [Attach Fabric-CA](https://github.com/rtfmplz/fabric-playground#attach-fabric-ca)
> * [Create, join channel & update Anchor peer](https://github.com/rtfmplz/fabric-playground#create-join-channel--update-anchor-peer)


## install chiancode

```bash
peer chaincode install -n pdc02 -v 1.0 -p github.com/chaincode/example02-pdc/go/
```

## instantiate chaincode

> Comment
> 
> * `-P "OR ('Org1MSP.member')"`는 `collections-config`에 포함되어 있으므로 생략
> * chaincode_example02.go의 `Init()`의 `PutState()`를 `PutPrivateData()`로만 바꿔서 그대로 사용하면 다음과 같은 Error 가 난다.
> * 하여, `Init()`의 내용을 주석처리하고, `set()` 함수를 추가 함
>
> ```
> Error: could not assemble transaction, err proposal response was not successful, error code 500, msg transaction returned with failure: PUT_STATE failed: transaction ID: e390654c44d60cd514c566d123f5f0afef69e44774df5432b5091e1d9f0002eb: private data APIs are not allowed in chaincode Init()
> ```

```bash
peer chaincode instantiate -o orderer1.ordererorg:7050 -C ch1 -n pdc02 -v 1.0 -c '{"Args":["init"]}' --collections-config 'pdc/collection-config.json'
```

## set a, b

```bash
peer chaincode invoke -o orderer1.ordererorg:7050 -C ch1 -n pdc02 --peerAddresses peer1.org1:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1/peers/peer1.org1/tls/ca.crt -c '{"Args":["set","a","100"]}'
peer chaincode invoke -o orderer1.ordererorg:7050 -C ch1 -n pdc02 --peerAddresses peer1.org1:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1/peers/peer1.org1/tls/ca.crt -c '{"Args":["set","b","100"]}'
```

## invoke

```bash
peer chaincode invoke -o orderer1.ordererorg:7050 -C ch1 -n pdc02 --peerAddresses peer1.org1:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1/peers/peer1.org1/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}'
```

## query

```bash
peer chaincode query -C ch1 -n pdc02 -c '{"Args":["query","a"]}'
```
