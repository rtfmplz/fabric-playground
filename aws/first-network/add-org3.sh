#!/bin/bash

CHANNEL_ARTIFACT="channel-artifact.json"

if [ -z ${CHANNEL_ARTIFACT} ]; then
  echo "CHANNEL_ARTIFACT is required."
  exit 1;
fi

pushd add-org3
terraform init
terraform apply
popd
