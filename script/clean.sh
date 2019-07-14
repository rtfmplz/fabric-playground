#!/bin/bash

rm -rf *.block
rm -rf *.tx
rm -rf crypto
rm -rf ./fabcar/hfc-key-store
#rm -rf ./fabcar/node_modules
rm -rf ./production
docker rmi $(docker images | grep dev)

