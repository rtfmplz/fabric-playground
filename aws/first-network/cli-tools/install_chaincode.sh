#!/bin/bash

#############################################
# Chaincode Install & Instantiate
#############################################

if [ -z $1 ]; then
  echo "CHAINCODE_NAME is mycc (default test chaincode)"
  CHAINCODE_NAME=${TEST_CHAINCODE_NAME}
else
  echo "CHAINCODE_NAME is $1"
  CHAINCODE_NAME=$1
fi

if [ -z $2 ]; then
  echo "CHANNEL_NAME is ch1 (default test channel)"
  CHANNEL_NAME=${TEST_CHANNEL_NAME}
else
  echo "CHANNEL_NAME is $1"
  CHANNEL_NAME=$1
fi

peer chaincode install -n ${CHAINCODE_NAME} -v 1.0 -p github.com/chaincode/chaincode_example02/go/

peer chaincode instantiate -o orderer0.ordererorg:57050 --tls --cafile $ORDERER_ORG_TLSCACERTS -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member')"

