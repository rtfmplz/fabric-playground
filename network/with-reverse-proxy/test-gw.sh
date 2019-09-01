#!/bin/bash

# import functions
. functions.sh

GATEWAY_ADDR="localhost:57999"

###############################################################

try "Example of GET and test for 404 status"
out=$(get_conn $URL/health)
assert "404" "$out"

###############################################################

# try "-> org1 g/w -> orderer1.ordererorg"
# out=$(get_common_name "orderer0.ordererorg:7050" "$ORG1_GW_IP")
# assert "orderer0" "$out"

###############################################################

echo
echo "PASS: $tests_run tests run"
