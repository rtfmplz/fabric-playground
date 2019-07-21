# Fabric-Playground

개인적인 관심으로 Hyperledger-Fabric의 기능들을 테스트하고, Dapp을 개발하기 위한 공간입니다.

2019년 7월 기준 Hyperledger-Fabric 1.4 기반으로 동작합니다.

필요한 환경 및 Binary, Docker image, SDK에 대한 정보는 아래 Link에서 얻을 수 있습니다.

* [[release 1.4] Prerequisites](https://hyperledger-fabric.readthedocs.io/en/release-1.4/prereqs.html)
* [[release 1.4] Install Samples, Binaries and Docker Images](https://hyperledger-fabric.readthedocs.io/en/release-1.4/install.html)
* [[release 1.4] SDK & CA](https://hyperledger-fabric.readthedocs.io/en/release-1.4/getting_started.html#hyperledger-fabric-sdks)

## Consist of

### [`network`](https://github.com/rtfmplz/fabric-playground/tree/master/network)

* 다양한 구성의 Fabric Network를 Docker Compose 를 이용해서 구성할 수 있다.

### [`docker-compose`](https://github.com/rtfmplz/fabric-playground/tree/master/docker-compose)

* network 및 기타 example들이 사용하는 docker-compose 파일들

### [`chaincode`](https://github.com/rtfmplz/fabric-playground/tree/master/chaincode)

* chaincode_example02, fabcar 등 Fabric의 기본 예제로 사용되는 chaincode들과 테스트 및 개인적인 목적으로 작성한 chaincode들

### [`dapps`](https://github.com/rtfmplz/fabric-playground/tree/master/dapps)

* chaincode를 동작시키는 dapp들 (chaincode 폴더 명과 동일한 이름으로 구성되어 있다.)

### [`examples`](https://github.com/rtfmplz/fabric-playground/tree/master/examples)

* network, dapp 등을 구현하는데 사용된 기술들을 검증하기 위한 간단한 샘플들

### [`monitoring`](https://github.com/rtfmplz/fabric-playground/tree/master/monitoring)

* Fabric network를 모니터링 하기 위한 툴 들, [blockchain-explorer](https://github.com/hyperledger/blockchain-explorer)를
바탕으로 본 프로젝트의 `network`에서 사용 가능하도록 수정 됨

### [`scripts`](https://github.com/rtfmplz/fabric-playground/tree/master/scripts)

* Project를 위해 필요한 간단한 Script들을 제공
