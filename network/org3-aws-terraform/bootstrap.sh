#!/bin/bash

##############################################################
# Variables
##############################################################
HYPERLEDGER_RESOURCES_DIR="${PWD}/terraform/resources/hyperledger"
CRYPTO_CONFIG_FILE="crypto.yaml"
ORDERER_TLS_CA_CERT_FILE="tlsca.ordererorg-cert.pem"
FABRIC_CFG_FILE="configtx.yaml"
CHANNEL_ARTIFACT="channel-artifact.json"
INTERVAL=1
DOCKER_NETWORK="hyperledger"

ORG_NAME="Org3"
if [ -n "$1" ]; then
  ORG_NAME=$1
fi

ORG_DOMAIN="org3.example.com"
if [ -n "$2" ]; then
  ORG_DOMAIN=$2
fi

OUTPUT_CRYPTO_DIR="${HYPERLEDGER_RESOURCES_DIR}/crypto"
ORDERER_TLS_CA_CERT_DIR="ordererOrganizations/ordererorg/msp/tlscacerts/"
CA_MSP_DIR="${OUTPUT_CRYPTO_DIR}/peerOrganizations/${ORG_DOMAIN}/ca/"

##############################################################
# Preprocessing : Create resource files
##############################################################
# CREATE CRYPTO CONFIG FILE
rm -rf ${CRYPTO_CONFIG_FILE}
cat << EOF >> ${CRYPTO_CONFIG_FILE}
---
PeerOrgs:
  - Name: ${ORG_NAME}
    Domain: ${ORG_DOMAIN}
    EnableNodeOUs: true
    Template:
      Count: 2
    Users:
      Count: 1
EOF

# CREATE FABRIC CFG FILE
rm -rf ${FABRIC_CFG_FILE}
cat << EOF >> ${FABRIC_CFG_FILE}
---
Organizations:
  - &${ORG_NAME}
    Name: ${ORG_NAME}
    ID: ${ORG_NAME}MSP
    MSPDir: ${OUTPUT_CRYPTO_DIR}/peerOrganizations/${ORG_DOMAIN}/msp
    AnchorPeers:
      - Host: peer0.${ORG_DOMAIN}
        Port: 7051
EOF

##############################################################
# Check resource files exist
##############################################################
[ -e ./${CRYPTO_CONFIG_FILE} ] && echo "${CRYPTO_CONFIG_FILE}: OK" || { echo "${CRYPTO_CONFIG_FILE} could not found."; exit 1; }
[ -e ./${ORDERER_TLS_CA_CERT_FILE} ] && echo "${ORDERER_TLS_CA_CERT_FILE}: OK" || { echo "${ORDERER_TLS_CA_CERT_FILE} could not found."; exit 1; }
#[ -e ./${HYPERLEDGER_RESOURCES_DIR}/.env ] && echo ".env: OK" || { echo ".env  could not found."; exit 1; }
[ -e ./${FABRIC_CFG_FILE} ] && echo "${FABRIC_CFG_FILE}: OK" || { echo "${FABRIC_CFG_FILE} could not found."; exit 1; }

##############################################################
# Create crypto materials
##############################################################
if [ -e ${OUTPUT_CRYPTO_DIR} ]; then
  rm -rf ${OUTPUT_CRYPTO_DIR}
fi
cryptogen generate --config=${CRYPTO_CONFIG_FILE} --output=${OUTPUT_CRYPTO_DIR}
sleep ${INTERVAL}

#############################################################
# COPY Orderer TLS CERT
##############################################################
mkdir -p ${OUTPUT_CRYPTO_DIR}/${ORDERER_TLS_CA_CERT_DIR}
cp ${ORDERER_TLS_CA_CERT_FILE} ${OUTPUT_CRYPTO_DIR}/${ORDERER_TLS_CA_CERT_DIR}
sleep ${INTERVAL}

##############################################################
# Create Org3 channel config
##############################################################
export FABRIC_CFG_PATH=${PWD}
configtxgen -printOrg ${ORG_NAME} > ${CHANNEL_ARTIFACT}
sleep ${INTERVAL}

##############################################################
# Update FABRIC_CA_SERVER_CA_KEYFILE
##############################################################
server_keyfile=$(tree ${CA_MSP_DIR} | grep "sk" | awk '{print $2}')
rm -rf ${HYPERLEDGER_RESOURCES_DIR}/.env
cat << EOF >> ${HYPERLEDGER_RESOURCES_DIR}/.env
ORG_NAME=${ORG_NAME}
ORG_DOMAIN=${ORG_DOMAIN}
DOCKER_NETWORK=${DOCKER_NETWORK}
FABRIC_CA_SERVER_CA_KEYFILE=${server_keyfile}

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
