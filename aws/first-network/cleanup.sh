pushd add-org3
if [ -e ./.terraform ]; then
    terraform destroy -auto-approve
    rm -rf terraform.tfstate
    rm -rf terraform.tfstate.backup
    rm -rf .terraform
fi
rm -rf ./channel-artifact.json
popd

pushd cli-tools
  rm -rf crypto
  rm -rf *.block
  rm -rf *.pb
  rm -rf *.json
  rm -rf *.tx
  rm -rf .env
popd

pushd bootstrap
if [ -e ./.terraform ]; then
    terraform destroy -auto-approve
    rm -rf terraform.tfstate
    rm -rf terraform.tfstate.backup
    rm -rf .terraform
    mv n-private-subnet.tf.bak n-private-subnet.tf
fi
popd

rm -rf ./artifacts
rm -rf ./crypto
rm -rf ./channel-artifact.json
rm -rf ./terraform.tfstate
