#!/bin/bash

rm -rf *.block
rm -rf *.tx
rm -rf crypto
rm -rf ./dapps/fabcar/wallet
#rm -rf ./dapps/fabcar/node_modules
rm -rf ./dapps/example02/wallet
#rm -rf ./dapps/example02/node_modules
rm -rf ./production
docker rmi $(docker images | grep dev)

