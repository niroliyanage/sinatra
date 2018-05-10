#!/bin/bash
source ./env.sh

cd "$(dirname "$0")"
cd ..
rm -rf .terraform
terraform init -input=false -backend-config "region=${TF_VAR_region}" -backend-config "bucket=${TF_VAR_bucket}" 
terraform workspace select sinatra || terraform workspace new sinatra
terraform plan -var-file=vars.tfvars -out=${tfplan}