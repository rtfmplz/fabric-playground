# Blockchain Explorer

1. clean docker volume

```bash
docker stop explorer explorerdb proms grafana
docker rm explorer explorerdb proms grafana
docker volume rm fabric-playground_walletstore fabric-playground_pgdata fabric-playground_grafana-storage fabric-playground_prometheus-storage
```

2. update adminPrivateKey of Org1 in  'connection-profile/network.json'

```bash
# in fabric-playground
tree ../crypto/peerOrganizations/org1/users/Admin@org1/msp/keystore/
../crypto/peerOrganizations/org1/users/Admin@org1/msp/keystore/
└── 0fd8860c5681adb64cf612633044f9a93b23975bf26f40edd515ff40beef3379_sk
```

3. docker-compose up

```bash
docker-compose up -d
```

> Explorer
>
> * [Explorer](http://localhost:8080/)
