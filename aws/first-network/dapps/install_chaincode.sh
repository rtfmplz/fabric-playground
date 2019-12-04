#!/bin/bash

#############################################
# Test Chaincode Install & Instantiate
#############################################

peer chaincode install -n ${TEST_CHAINCODE_NAME} -v 1.0 -p github.com/chaincode/chaincode_example02/go/

peer chaincode instantiate -o orderer0.ordererorg:57050 --tls --cafile $ORDERER_ORG_TLSCACERTS -C ${TEST_CHANNEL_NAME} -n ${TEST_CHAINCODE_NAME} -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member')"

