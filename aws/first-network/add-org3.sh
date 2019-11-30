#!/bin/bash

CHANNEL_ARTIFACT="./add-org3/channel-artifact.json"
ADMIN_EC2_PUBLIC_IP=""

if [ ! -e ${CHANNEL_ARTIFACT} ]; then
  echo "CHANNEL_ARTIFACT is required."
  exit 1;
fi

ADMIN_EC2_PUBLIC_IP=$1
if [ -z ${ADMIN_EC2_PUBLIC_IP} ]; then
  echo "admin_ec2_public_ip is required."
  exit 1;
else
  echo "admin_ec2_public_ip: $ADMIN_EC2_PUBLIC_IP"
fi

pushd add-org3
terraform init
terraform apply -auto-approve -var="admin_ec2_public_ip=$ADMIN_EC2_PUBLIC_IP"
popd
