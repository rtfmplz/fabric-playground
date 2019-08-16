#!/bin/bash

##############################################################
# minimal network 를 구성하기 위한 스트립트
##############################################################

##############################################################
# Variables
##############################################################
CRYPTO_CONFIG_FILE="crypto-config.yaml"
OUTPUT_CRYPTO_DIR="./crypto"
GENESIS_BLOCK="genesis.block"
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
if [ -e ${OUTPUT_CRYPTO_DIR} ]; then
  rm -rf ${OUTPUT_CRYPTO_DIR}
fi
cryptogen generate --config=${CRYPTO_CONFIG_FILE} --output=${OUTPUT_CRYPTO_DIR}
sleep ${INTERVAL}

##############################################################
# Create genesis.block
##############################################################
if [ -e ./${GENESIS_BLOCK} ]; then
  rm -rf ./${GENESIS_BLOCK}
fi
configtxgen -profile OrgsOrdererGenesis -outputBlock ${GENESIS_BLOCK}
sleep ${INTERVAL}

##############################################################
# Create channel configuration
##############################################################
if [ -e ./${CHANNEL_CONF_TX} ]; then
  rm -rf ./${CHANNEL_CONF_TX}
fi
configtxgen -profile OrgsChannel -outputCreateChannelTx ${CHANNEL_CONF_TX} -channelID ${CHANNEL_NAME}
sleep ${INTERVAL}

##############################################################
# Create org1 anchor peer update configuration
##############################################################
if [ -e ./${ANCHOR_PEER_UPDATE_TX} ]; then
  rm -rf ./${ANCHOR_PEER_UPDATE_TX}
fi
configtxgen -profile OrgsChannel -outputAnchorPeersUpdate ${ANCHOR_PEER_UPDATE_TX} -channelID ${CHANNEL_NAME} -asOrg ${ORG_NAME}
sleep ${INTERVAL}

##############################################################
# Remove ledgerdata & docker-compose down
##############################################################
if [ -e ./${PRODUCTION_DIR} ]; then
  rm -rf ./${PRODUCTION_DIR}
fi
docker-compose down
sleep ${INTERVAL}

##############################################################
# Remove Chaincode Container
##############################################################
chaincode_images_count=`docker images | grep dev | wc -l`
if [ $chaincode_images_count -gt 0 ]; then
  docker rmi $(docker images | grep dev)
fi
sleep ${INTERVAL}

##############################################################
# Create docker network
##############################################################
is_network=`docker network ls | grep ${DOCKER_NETWORK} | wc -l`
if [ $is_network -eq 1 ]; then
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
