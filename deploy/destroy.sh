#!/bin/bash
source ./env.sh


cd "$(dirname "$0")"
cd ..
rm -rf .terraform
terraform init -input=false -backend-config "region=${TF_VAR_region}"
terraform workspace select sinatra || terraform workspace new sinatra

terraform destroy -force -var-file=vars.tfvars