pushd join-channel
if [ -e ./.terraform ]; then
    terraform destroy -auto-approve
    rm -rf terraform.tfstate
    rm -rf terraform.tfstate.backup
    rm -rf .terraform
fi
rm -rf ./channel-artifact.json
popd

pushd bootstrap
if [ -e ./.terraform ]; then
    terraform destroy -auto-approve
    rm -rf terraform.tfstate
    rm -rf terraform.tfstate.backup
    rm -rf .terraform
fi
popd

rm -rf ./artifacts
rm -rf ./crypto.yaml
rm -rf ./configtx.yaml
rm -rf ./tlsca.ordererorg-cert.pem
rm -rf ./terraform.tfstate
