#!/bin/bash

#############################################
# Create Test Channel & Join
#############################################

peer channel create -o orderer0.ordererorg:7050 -c ${TEST_CHANNEL_NAME} -f ${TEST_CHANNEL_NAME}.tx --tls --cafile $ORDERER_ORG_TLSCACERTS

peer channel join -b ${TEST_CHANNEL_NAME}.block

peer channel update -o orderer0.ordererorg:7050 -c ${TEST_CHANNEL_NAME} -f ./updateAnchorOrg1.tx --tls --cafile $ORDERER_ORG_TLSCACERTS

#############################################
# Test Chaincode Install & Instantiate
#############################################

peer chaincode install -n ${TEST_CHAINCODE_NAME} -v 1.0 -p github.com/chaincode/chaincode_example02/go/

peer chaincode instantiate -o orderer0.ordererorg:7050 --tls --cafile $ORDERER_ORG_TLSCACERTS -C ${TEST_CHANNEL_NAME} -n ${TEST_CHAINCODE_NAME} -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member')"

