#!/bin/bash

#############################################
# Create & Join Channel
#############################################

if [ -z $1 ]; then
  echo "CHANNEL_NAME is ch1 (default test channel)"
  exit 1
else
  echo "CHANNEL_NAME is $1"
  CHANNEL_NAME=$1
fi

#[ -n "${CHANNEL_NAME}" ] && echo "${CHANNEL_NAME}: OK" || { echo "CHANNEL_NAME environment is empty"; exit 1; }
[ -e ${CHANNEL_NAME}.tx ] && echo "${CHANNEL_NAME}.tx: EXIST" || { echo "${CHANNEL_NAME}.tx could not found."; exit 1; }
[ -n "${ORDERER_ORG_TLSCACERTS}" ] && echo "${ORDERER_ORG_TLSCACERTS}: OK" || { echo "ORDERER_ORG_TLSCACERTS environment is empty"; exit 1; }
[ -e ${ORDERER_ORG_TLSCACERTS} ] && echo "${ORDERER_ORG_TLSCACERTS}: EXIST" || { echo "${ORDERER_ORG_TLSCACERTS} could not found."; exit 1; }

peer channel create -o orderer0.ordererorg:57050 -c ${CHANNEL_NAME} -f ${CHANNEL_NAME}.tx --tls --cafile $ORDERER_ORG_TLSCACERTS

peer channel join -b ${CHANNEL_NAME}.block

peer channel update -o orderer0.ordererorg:57050 -c ${CHANNEL_NAME} -f ./updateAnchorOrg1.tx --tls --cafile $ORDERER_ORG_TLSCACERTS

