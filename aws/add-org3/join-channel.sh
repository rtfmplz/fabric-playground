#!/bin/bash

ADMIN_EC2_PUBLIC_IP=""

ADMIN_EC2_PUBLIC_IP=$1
if [ -z ${ADMIN_EC2_PUBLIC_IP} ]; then
  echo "admin_ec2_public_ip is required."
  exit 1;
else
  echo "admin_ec2_public_ip: $ADMIN_EC2_PUBLIC_IP"
fi

pushd join-channel
terraform init
terraform apply -auto-approve -var="admin_ec2_public_ip=$ADMIN_EC2_PUBLIC_IP"
popd
