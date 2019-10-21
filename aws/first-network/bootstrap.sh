#!/bin/bash

##############################################################
# Variables
##############################################################
FABRIC_RESOURCES_DIR="${PWD}/terraform/resources/hyperledger"
NGINX_RESOURCES_DIR="${PWD}/terraform/resources/nginx"

GENESIS_BLOCK="genesis.block"
CHANNEL_NAME="ch1"
CHANNEL_CONF_TX=${CHANNEL_NAME}.tx
ANCHOR_PEER_UPDATE_TX="updateAnchorOrg1.tx"

CRYPTO_CONFIG_FILE="crypto.yaml"
ORDERER_TLS_CA_CERT_FILE="tlsca.ordererorg-cert.pem"
FABRIC_CFG_FILE="configtx.yaml"
CHANNEL_ARTIFACT="channel-artifact.json"
INTERVAL=1
DOCKER_NETWORK="hyperledger"

ORDERER_ORG_NAME="OrdererOrg"
ORDERER_ORG_HOSTNAME="orderer0"
ORDERER_ORG_DOMAIN="ordererorg"


HOST_ORG_GW_IP="127.0.0.1"
if [ -z ${HOST_ORG_GW_IP} ]; then
  echo "HOST_ORG_GW_IP is required."
  exit 1;
fi

ORG_NAME="Org1"
if [ -n "$1" ]; then
  ORG_NAME=$1
fi

ORG_DOMAIN="org1.example.com"
if [ -n "$2" ]; then
  ORG_DOMAIN=$2
fi

ORG3_DOMAIN="org3.example.com"

OUTPUT_CRYPTO_DIR="crypto"
ORDERER_TLS_CA_CERT_DIR="ordererOrganizations/ordererorg/msp/tlscacerts/"
CA_MSP_DIR="${OUTPUT_CRYPTO_DIR}/peerOrganizations/${ORG_DOMAIN}/ca/"

export FABRIC_CFG_PATH=${PWD}


##############################################################
# Check resource files exist
##############################################################
[ -e ./${CRYPTO_CONFIG_FILE} ] && echo "${CRYPTO_CONFIG_FILE}: OK" || { echo "${CRYPTO_CONFIG_FILE} could not found."; exit 1; }
# [ -e ./${ORDERER_TLS_CA_CERT_FILE} ] && echo "${ORDERER_TLS_CA_CERT_FILE}: OK" || { echo "${ORDERER_TLS_CA_CERT_FILE} could not found."; exit 1; }
#[ -e ./${FABRIC_RESOURCES_DIR}/.env ] && echo ".env: OK" || { echo ".env  could not found."; exit 1; }
[ -e ./${FABRIC_CFG_FILE} ] && echo "${FABRIC_CFG_FILE}: OK" || { echo "${FABRIC_CFG_FILE} could not found."; exit 1; }


##############################################################
# Preprocessing
##############################################################
echo $FABRIC_CFG_PATH

##############################################################
# Create crypto materials
##############################################################
if [ -e ${FABRIC_RESOURCES_DIR}/${OUTPUT_CRYPTO_DIR} ]; then
  rm -rf ${OUTPUT_CRYPTO_DIR}
  rm -rf ${FABRIC_RESOURCES_DIR}/${OUTPUT_CRYPTO_DIR}
fi
cryptogen generate --config=${CRYPTO_CONFIG_FILE} --output=./${OUTPUT_CRYPTO_DIR}
cp -avR ${OUTPUT_CRYPTO_DIR} ${FABRIC_RESOURCES_DIR}
sleep ${INTERVAL}


##############################################################
# Create genesis.block
##############################################################
if [ -e ./${FABRIC_RESOURCES_DIR}/${GENESIS_BLOCK} ]; then
  rm -rf ./${FABRIC_RESOURCES_DIR}/${GENESIS_BLOCK}
fi
configtxgen -profile OrgsOrdererGenesis -outputBlock ${FABRIC_RESOURCES_DIR}/${GENESIS_BLOCK}
sleep ${INTERVAL}

##############################################################
# Create channel configuration
##############################################################
if [ -e ./${FABRIC_RESOURCES_DIR}/${CHANNEL_CONF_TX} ]; then
  rm -rf ./${FABRIC_RESOURCES_DIR}/${CHANNEL_CONF_TX}
fi
configtxgen -profile OrgsChannel -outputCreateChannelTx ${FABRIC_RESOURCES_DIR}/${CHANNEL_CONF_TX} -channelID ${CHANNEL_NAME}
sleep ${INTERVAL}

##############################################################
# Create org1 anchor peer update configuration
##############################################################
if [ -e ./${FABRIC_RESOURCES_DIR}/${ANCHOR_PEER_UPDATE_TX} ]; then
  rm -rf ./${FABRIC_RESOURCES_DIR}/${ANCHOR_PEER_UPDATE_TX}
fi
configtxgen -profile OrgsChannel -outputAnchorPeersUpdate ${FABRIC_RESOURCES_DIR}/${ANCHOR_PEER_UPDATE_TX} -channelID ${CHANNEL_NAME} -asOrg ${ORG_NAME}
sleep ${INTERVAL}



##############################################################
# Create .env for fabric
##############################################################
server_keyfile=$(tree ${FABRIC_RESOURCES_DIR}/${CA_MSP_DIR} | grep "sk" | awk '{print $2}')
rm -rf ${FABRIC_RESOURCES_DIR}/.env
cat << EOF >> ${FABRIC_RESOURCES_DIR}/.env
ORDERER_ORG_NAME=${ORDERER_ORG_NAME}
ORDERER_ORG_HOSTNAME=${ORDERER_ORG_HOSTNAME}
ORDERER_ORG_DOMAIN=${ORDERER_ORG_DOMAIN}
ORG_NAME=${ORG_NAME}
ORG_DOMAIN=${ORG_DOMAIN}
DOCKER_NETWORK=${DOCKER_NETWORK}
FABRIC_CA_SERVER_CA_KEYFILE=${server_keyfile}

EOF
sleep ${INTERVAL}

##############################################################
# Create .env for nginx
##############################################################
rm -rf ${NGINX_RESOURCES_DIR}/.env
cat << EOF >> ${NGINX_RESOURCES_DIR}/.env
ORDERER_ORG_NAME=${ORDERER_ORG_NAME}
ORDERER_ORG_HOSTNAME=${ORDERER_ORG_HOSTNAME}
ORDERER_ORG_DOMAIN=${ORDERER_ORG_DOMAIN}
ORG_NAME=${ORG_NAME}
ORG3_DOMAIN=${ORG3_DOMAIN}
DOCKER_NETWORK=${DOCKER_NETWORK}

EOF
sleep ${INTERVAL}

#############################################################
# export AWS_ACCESS_KEY
##############################################################



#############################################################
# Bootstrap network
##############################################################
pushd terraform
terraform init
terraform apply
popd
