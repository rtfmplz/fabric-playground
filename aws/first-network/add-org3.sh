#!/bin/bash

CHANNEL_ARTIFACT="./add-org3/channel-artifact.json"

if [ ! -e ${CHANNEL_ARTIFACT} ]; then
  echo "CHANNEL_ARTIFACT is required."
  exit 1;
fi

pushd add-org3
terraform init
terraform apply -auto-approve
popd
