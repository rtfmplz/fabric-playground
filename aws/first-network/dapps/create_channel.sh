#!/bin/bash

#############################################
# Create Test Channel & Join
#############################################

peer channel create -o orderer0.ordererorg:57050 -c ${TEST_CHANNEL_NAME} -f ${TEST_CHANNEL_NAME}.tx --tls --cafile $ORDERER_ORG_TLSCACERTS

peer channel join -b ${TEST_CHANNEL_NAME}.block

peer channel update -o orderer0.ordererorg:57050 -c ${TEST_CHANNEL_NAME} -f ./updateAnchorOrg1.tx --tls --cafile $ORDERER_ORG_TLSCACERTS


