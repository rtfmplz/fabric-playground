#!/bin/bash

rm -rf *.block
rm -rf *.tx
rm -rf crypto
rm -rf ./production
docker stop $(docker ps -aq) && docker rm $(docker ps -aq)
docker rmi $(docker images | grep dev)

