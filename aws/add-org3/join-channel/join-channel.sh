#!/bin/bash

peer channel fetch 0 $TEST_CHANNEL_NAME.block -o orderer0.ordererorg:7050 -c $TEST_CHANNEL_NAME --tls --cafile $ORDERER_ORG_TLSCACERTS
peer channel join -b $TEST_CHANNEL_NAME.block
peer chaincode install -n ${TEST_CHAINCODE_NAME} -v 1.0 -p github.com/chaincode/chaincode_example02/go/
sleep 10
peer chaincode query -C ${TEST_CHANNEL_NAME} -n ${TEST_CHAINCODE_NAME} -c '{"Args":["query","a"]}'
