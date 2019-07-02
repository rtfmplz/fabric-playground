# Private Data Collection Example

> hyperledger-fabric network 는 미리 구동시켜 놓자, 아래 참조
>
> * [BootStrap Fabric Network](https://github.com/rtfmplz/fabric-playground#bootstrap-fabric-network)
> * [Attach Fabric-CA](https://github.com/rtfmplz/fabric-playground#attach-fabric-ca)
> * [Create, join channel & update Anchor peer](https://github.com/rtfmplz/fabric-playground#create-join-channel--update-anchor-peer)


## install chiancode

```bash
docker exec -it cli bash
peer chaincode install -n example02_pdc -v 1.0 -p github.com/chaincode/example02_pdc/go/
```

## instantiate chaincode

> ## private data APIs are not allowed in chaincode Init()
> 
> * chaincode_example02.go의 `Init()`의 `PutState()`를 `PutPrivateData()`로만 바꿔서 그대로 사용하면 다음과 같은 Error 가 난다.
> * 하여, `Init()`의 내용을 주석처리하고, `init()` 함수를 추가 함
>
> ```
> Error: could not assemble transaction, err proposal response was not successful, error code 500, msg transaction returned with failure: PUT_STATE failed: transaction ID: e390654c44d60cd514c566d123f5f0afef69e44774df5432b5091e1d9f0002eb: private data APIs are not allowed in chaincode Init()
> ```

```bash
peer chaincode instantiate -o orderer1.ordererorg:7050 -C ch1 -n example02_pdc -v 1.0 -c '{"Args":["init"]}' -P "OR ('Org1MSP.member')" --collections-config 'example-pdc/collection-config.json'
```

#### collection-config.json

```json
[
	{
		// pdc 이름
		"name": "pdc_org1_org2",

		// private data collection 배포 정책은 private data를 공유할 조직의 peer를 정의한다.
		// 서명 정책 구문을 사용하여 표현된다. ([fabric-sdk-node의 tutorial](https://fabric-sdk-node.github.io/release-1.4/tutorial-private-data.html)을 보면 json 형태로도 표현 가능한 듯)
		"policy": "OR('Org1MSP.member', 'Org2MSP.member')",
		
		// endorsing peer가 endorsement에 서명전 private data를 배급해야 하는 필수 peer 수
		// endorsement의 조건으로 private data의 보급을 요구해서, endorsing peer가 죽은 경우에도 private data를 사용하도록 하는 안전장치 역할
		"requiredPeerCount": 0,
		
		// 데이터 중복성을 위해서 endorsing peer가 데이터를 배포하려고 시도하는 다른  peer의 수
		"maxPeerCount": 2, 
		
		// private data가 유지될 block 수
		"blockToLive": 0, //
		
		// true로 설정 시, collection member orgization에 속한 client만 데이터 읽기가 가능
		"memberOnlyRead": true
	}
]
```


## init

```bash
export INIT_DATA=$(echo -n "{\"a_name\":\"a\",\"a_val\":100,\"b_name\":\"b\",\"b_val\":100}" | base64)
peer chaincode invoke -o orderer1.ordererorg:7050 -C ch1 -n example02_pdc --peerAddresses peer1.org1:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1/peers/peer1.org1/tls/ca.crt -c '{"Args":["init"]}' --transient "{\"initData\":\"$INIT_DATA\"}"
```

## invoke

```bash
export TRANSFER_DATA=$(echo -n "{\"sender\":\"a\",\"receiver\":\"b\",\"val\":10}" | base64)
peer chaincode invoke -o orderer1.ordererorg:7050 -C ch1 -n example02_pdc --peerAddresses peer1.org1:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1/peers/peer1.org1/tls/ca.crt -c '{"Args":["invoke"]}' --transient "{\"transferData\":\"$TRANSFER_DATA\"}"
```

## query

```bash
peer chaincode query -C ch1 -n example02_pdc -c '{"Args":["query","a"]}'
```


## reference

* [How to use private data](https://fabric-sdk-node.github.io/release-1.4/tutorial-private-data.html)
* [Private Data Concept](https://hyperledger-fabric.readthedocs.io/en/release-1.4/private-data/private-data.html)
* [Private Data Architecture](https://hyperledger-fabric.readthedocs.io/en/release-1.4/private-data-arch.html)
* [Using Private Data in Fabric](https://hyperledger-fabric.readthedocs.io/en/release-1.4/private_data_tutorial.html)
