
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
rm -rf ./crypto.yaml
rm -rf ./configtx.yaml
rm -rf ./tlsca.ordererorg-cert.pem
rm -rf ./public-load-balancer-dns-name.org1
rm -rf ./terraform.tfstate
