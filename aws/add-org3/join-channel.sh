#!/bin/bash

pushd join-channel
terraform init
terraform apply -auto-approve
popd
