#!/bin/bash

# import functions
source test-function.sh

GATEWAY_IP="127.0.0.1"
GATEWAY_ADDR="127.0.0.1:57999"
GATEWAY_ADDR_FOR_ORDERER1="127.0.0.1:57051"
GATEWAY_ADDR_FOR_PEER1="127.0.0.1:57050"
GATEWAY_ADDR_FOR_PEER2="127.0.0.1:58050"


###############################################################
# HEALTH CHECK
###############################################################

try "org1_gw health check"
out=$(curl $GATEWAY_ADDR/health --silent --stderr - | awk '{print $1}')
assert "OK" "$out"

###############################################################
# IP:PORT로 접속 테스트
###############################################################

try "-> org1_gw"
out=$(get_conn $GATEWAY_ADDR)
assert "$GATEWAY_ADDR" "$out"

###############################################################
# CN(Common Name) 확인 테스트
###############################################################

try "-> org1 g/w -> orderer1.ordererorg"
out=$(get_cn "orderer1.ordererorg:57050" "$GATEWAY_IP")
assert "CN=orderer1.ordererorg" "$out"

try "-> org1 g/w -> peer1.org1"
out=$(get_cn "peer1.org1:57051" "$GATEWAY_IP")
assert "CN=peer1.org1" "$out"

try "-> org1 g/w -> peer2.org1"
out=$(get_cn "peer2.org1:57051" "$GATEWAY_IP")
assert "CN=peer2.org1" "$out"
###############################################################

echo
echo "PASS: $tests_run tests run"
