#!/bin/bash

peer channel fetch config config_block.pb -o orderer0.ordererorg:7050 -c $TEST_CHANNEL_NAME --tls --cafile $ORDERER_ORG_TLSCACERTS
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' ./config.json ./channel-artifact.json > ./modified_config.json
configtxlator proto_encode --input ./config.json --type common.Config >original_config.pb
configtxlator proto_encode --input ./modified_config.json --type common.Config >modified_config.pb
configtxlator compute_update --channel_id "${TEST_CHANNEL_NAME}" --original original_config.pb --updated modified_config.pb >config_update.pb
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate >config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$TEST_CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope >org3_update_in_envelope.pb
peer channel signconfigtx -f "org3_update_in_envelope.pb"
peer channel update -f org3_update_in_envelope.pb -c $TEST_CHANNEL_NAME -o orderer0.ordererorg:7050 --tls --cafile $ORDERER_ORG_TLSCACERTS