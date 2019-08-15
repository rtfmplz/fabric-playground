cryptogen generate --config=crypto-config.yaml --output=crypto
sleep 2
configtxgen -profile OrgsOrdererGenesis -outputBlock genesis.block
sleep 2
configtxgen -profile OrgsChannel -outputCreateChannelTx ch1.tx -channelID ch1
sleep 2
configtxgen -profile OrgsChannel -outputAnchorPeersUpdate updateAnchorOrg1.tx -channelID ch1 -asOrg Org1
sleep 2
docker stop $(docker ps -aq) && docker rm $(docker ps -aq) && rm -rf ./production
sleep 2
docker rmi $(docker images | grep dev)
sleep 2
docker network create fabric-minimal
sleep 2
tree crypto/peerOrganizations/org1/ca/ | grep sk | awk '{print "FABRIC_CA_SERVER_CA_KEYFILE="$2}' | xargs -I {} sed -i -e 's/^FABRIC_CA_SERVER_CA_KEYFILE=.*$/{}/g' .env
sleep 2
docker-compose up -d
