# Blockchain Explorer

## Prerequisites

* Clean up docker image and volume

```bash
docker stop explorer explorerdb proms grafana && docker rm explorer explorerdb proms grafana
```

```bash
docker volume rm fabric-playground_walletstore fabric-playground_pgdata fabric-playground_grafana-storage fabric-playground_prometheus-storage
```

* Update env file

```bash
COMPOSE_PROJECT_NAME=fabric-playground
FABRIC_PLAYGROUND=/Users/jae/git/fabric-playground/
```

* Update adminPrivateKey of Org1 in `explorer/connection-profile/network.json`

```bash
# in fabric-playground
tree ../crypto/peerOrganizations/org1/users/Admin@org1/msp/keystore/
../crypto/peerOrganizations/org1/users/Admin@org1/msp/keystore/
└── 0fd8860c5681adb64cf612633044f9a93b23975bf26f40edd515ff40beef3379_sk
```

> 만약 Fabric Network의 구성이 다르다면 `explorer/connection-profile/network.json` 파일을 적절하게 수정해줘야 한다.

## docker-compose up

```bash
docker-compose up -d
```


## Explorer

* [Explorer](http://localhost:8080/)

## Metrics & Monitoring

* [Prometheus](http://localhost:9090/)
* [Grafana](http://localhost:3000/)

Peer나 Orderer가 추가 된다면 아래 환경 변수가 적절하게 변경되어야 한다.

* Peer
    * CORE_METRICS_PROVIDER=prometheus
    * CORE_OPERATIONS_LISTENADDRESS=peer1.org1:9443
    * CORE_OPERATIONS_TLS_ENABLED=false

* Orderer
    * ORDERER_METRICS_PROVIDER=prometheus
    * ORDERER_OPERATIONS_LISTENADDRESS=orderer1.ordererorg:9443
    * ORDERER_OPERATIONS_TLS_ENABLED=false

