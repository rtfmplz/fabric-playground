#!/bin/bash

pushd join-channel
terraform init
terraform apply
popd
