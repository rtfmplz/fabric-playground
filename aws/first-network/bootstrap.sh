#!/bin/bash

##############################################################
# Variables
##############################################################
if [ -z ${TEST_CHAINCODE_NAME} ]; then
  echo "TEST_CHAINCODE_NAME is required."
  exit 1;
fi

if [ -z ${TEST_CHANNEL_NAME} ]; then
  echo "TEST_CHANNEL_NAME is required."
  exit 1;
fi

if [ -z "${ORG_NAME}" ]; then
  echo "ORG_NAME is required."
  exit 1;
fi

if [ -z "${ORG_DOMAIN}" ]; then
  echo "ORG_DOMAIN is required."
  exit 1;
fi

if [ -z "${ORDERER_ORG_NAME}" ]; then
  echo "ORDERER_ORG_NAME is required."
  exit 1;
fi

if [ -z "${ORDERER_ORG_DOMAIN}" ]; then
  echo "ORDERER_ORG_DOMAIN is required."
  exit 1;
fi

CHANNEL_CONF_TX="${TEST_CHANNEL_NAME}.tx"
FABRIC_RESOURCES_DIR="${PWD}/terraform/resources/hyperledger"
NGINX_RESOURCES_DIR="${PWD}/terraform/resources/nginx"
GENESIS_BLOCK="genesis.block"
ANCHOR_PEER_UPDATE_TX="updateAnchorOrg1.tx"
CRYPTO_CONFIG_FILE="crypto.yaml"
FABRIC_CFG_FILE="configtx.yaml"
CHANNEL_ARTIFACT="channel-artifact.json"
INTERVAL=1
DOCKER_NETWORK="hyperledger"
ORDERER_ORG_HOSTNAME="orderer0"
ORG3_DOMAIN="org3.example.com"
OUTPUT_CRYPTO_DIR="crypto"
ORDERER_TLS_CA_CERT_DIR="ordererOrganizations/${ORDERER_ORG_DOMAIN}/msp/tlscacerts/"
ORDERER_TLS_CA_CERT_FILE="tlsca.${ORDERER_ORG_DOMAIN}-cert.pem"

CA_MSP_DIR="${OUTPUT_CRYPTO_DIR}/peerOrganizations/${ORG_DOMAIN}/ca/"


export FABRIC_CFG_PATH=${PWD}

##############################################################
# Check resource files exist
##############################################################
[ -e ./${CRYPTO_CONFIG_FILE} ] && echo "${CRYPTO_CONFIG_FILE}: OK" || { echo "${CRYPTO_CONFIG_FILE} could not found."; exit 1; }
#[ -e ./${FABRIC_RESOURCES_DIR}/.env ] && echo ".env: OK" || { echo ".env  could not found."; exit 1; }
[ -e ./${FABRIC_CFG_FILE} ] && echo "${FABRIC_CFG_FILE}: OK" || { echo "${FABRIC_CFG_FILE} could not found."; exit 1; }


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
if [ -e ${FABRIC_RESOURCES_DIR}/${GENESIS_BLOCK} ]; then
  rm -rf ${FABRIC_RESOURCES_DIR}/${GENESIS_BLOCK}
fi
configtxgen -profile OrgsOrdererGenesis -outputBlock ${FABRIC_RESOURCES_DIR}/${GENESIS_BLOCK}
sleep ${INTERVAL}

##############################################################
# Create channel configuration
##############################################################
if [ -e ${FABRIC_RESOURCES_DIR}/${CHANNEL_CONF_TX} ]; then
  rm -rf ${FABRIC_RESOURCES_DIR}/${CHANNEL_CONF_TX}
fi
configtxgen -profile OrgsChannel -outputCreateChannelTx ${FABRIC_RESOURCES_DIR}/${CHANNEL_CONF_TX} -channelID ${TEST_CHANNEL_NAME}
sleep ${INTERVAL}

##############################################################
# Create org1 anchor peer update configuration
##############################################################
if [ -e ${FABRIC_RESOURCES_DIR}/${ANCHOR_PEER_UPDATE_TX} ]; then
  rm -rf ${FABRIC_RESOURCES_DIR}/${ANCHOR_PEER_UPDATE_TX}
fi
configtxgen -profile OrgsChannel -outputAnchorPeersUpdate ${FABRIC_RESOURCES_DIR}/${ANCHOR_PEER_UPDATE_TX} -channelID ${TEST_CHANNEL_NAME} -asOrg ${ORG_NAME}
sleep ${INTERVAL}



##############################################################
# Create .env for fabric
##############################################################
server_keyfile=$(tree ${FABRIC_RESOURCES_DIR}/${CA_MSP_DIR} | grep "sk" | awk '{print $2}')
rm -rf ${FABRIC_RESOURCES_DIR}/.env
cat << EOF >> ${FABRIC_RESOURCES_DIR}/.env
TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME}
TEST_CHAINCODE_NAME=${TEST_CHAINCODE_NAME}
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
# Prepare artifacts dir
##############################################################
if [ -e ./artifacts ]; then
  rm -rf ./artifacts
fi
mkdir ./artifacts
cp ./${OUTPUT_CRYPTO_DIR}/${ORDERER_TLS_CA_CERT_DIR}/${ORDERER_TLS_CA_CERT_FILE} ./artifacts


#############################################################
# Bootstrap network
##############################################################
pushd terraform
terraform init
terraform apply
echo "aws_lb.public-load-balancer.dns_name" | terraform console > ../artifacts/public-load-balancer-dns-name.org1
echo "aws_instance.admin.public_ip" | terraform console > ../artifacts/admin-ec2-public-ip.org1
popd
