#!/bin/bash
# minimal network 를 구성하기 위한 스트립트

CRYPTO_CONFIG_FILE="crypto-config.yaml"
OUTPUT_CRYPTO_DIR="./crypto"
GENESIS_FILE="genesis.block"
CHANNEL_NAME="ch1"
CHANNEL_CONF_TX=${CHANNEL_NAME}.tx
ANCHOR_PEER_UPDATE_TX="updateAnchorOrg1.tx"
ORG_NAME="Org1"
PRODUCTION_DIR="./production"
DOCKER_NETWORK="fabric-minimal"

INTERVAL=1

##############################################################
# Create crypto materials
##############################################################
if [ -e ./crypto ]; then
  rm -rf ./crypto
fi
cryptogen generate --config=${CRYPTO_CONFIG_FILE} --output=${OUTPUT_CRYPTO_DIR}
sleep ${INTERVAL}

##############################################################
# Create genesis.block
##############################################################
if [ -e ./${GENESIS_FILE} ]; then
  rm -rf ./${GENESIS_FILE}
fi
configtxgen -profile OrgsOrdererGenesis -outputBlock ${GENESIS_FILE}
sleep ${INTERVAL}

##############################################################
# Create channel configuration
##############################################################
if [ -e ./${CHANNEL_NAME} ]; then
  rm -rf ./${CHANNEL_NAME}
fi
configtxgen -profile OrgsChannel -outputCreateChannelTx ${CHANNEL_NAME}.tx -channelID ${CHANNEL_NAME}
sleep ${INTERVAL}

##############################################################
# Create org1 anchor peer update configuration
##############################################################
if [ -e ./${CHANNEL_NAME} ]; then
  rm -rf ./${CHANNEL_NAME}
fi
configtxgen -profile OrgsChannel -outputAnchorPeersUpdate ${ANCHOR_PEER_UPDATE_TX} -channelID ${CHANNEL_NAME} -asOrg ${ORG_NAME}
sleep ${INTERVAL}

##############################################################
# Remove ledgerdata & docker-compose stop
##############################################################
if [ -e ./${PRODUCTION_DIR} ]; then
  # docker stop $(docker ps -aq) && docker rm $(docker ps -aq) && rm -rf ${PRODUCTION_DIR}
  rm -rf ./${PRODUCTION_DIR}
  docker-compose stop
  docker rmi $(docker images | grep dev)
  sleep ${INTERVAL}
fi

##############################################################
# Create docker network
##############################################################
is_network=`docker network ls | grep ${DOCKER_NETWORK} | wc -l`
if [ $is_network -eq "1" ]; then
  echo "${DOCKER_NETWORK} is already exist"
else
  docker network create ${DOCKER_NETWORK}
fi
sleep ${INTERVAL}

##############################################################
# Update FABRIC_CA_SERVER_CA_KEYFILE
# [FIXME] Why created .env-e
##############################################################
tree crypto/peerOrganizations/org1/ca/ | grep sk | awk '{print "FABRIC_CA_SERVER_CA_KEYFILE="$2}' | xargs -I {} sed -i -e 's/^FABRIC_CA_SERVER_CA_KEYFILE=.*$/{}/g' .env
sleep ${INTERVAL}

#############################################################
# Bootstrap network
##############################################################
docker-compose up -d
