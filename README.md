# Deployment of Simple Sinatra app

### Technologies used 

Terraform
AWS
Shell scripting

## Prerequisites

Terraform - Version 0.11.7 from homebrew

AWS account - (Feel free to use mine, keys  emailed )

## Steps to deploy

### Clone Repo
```
git clone https://github.com/niroliyanage/sinatra.git
```

If you want to use your own AWS account be used , an account with Administrator  Privileges is required (Essentially instances would assume roles with administrator privileges upon provisioning , for the case of this assesment i've just used an account with admin privileges ). 

Please ensure the following vars are updated in the ```deploy/env.sh```

```
export TF_VAR_access_key="xxxxxx"
export TF_VAR_secret_key="xxxxx"
export TF_VAR_cloudflare_token="xxxx"
```


### Navigate to the deploy folder
```
cd sinatra/deploy
```
Run the terraform plan
```
./plan.sh
```
Run the Terraform apply 
```
./apply.sh
```
This will deploy a VPC, Subnets, Routing, Security groups along with access rules, an application load balancer and an ec2 instance where the sinatra app will get deployed when started. 

Once the Terraform apply completes you will see the output at the end similar to the following,

```
instance ssh ip = 13.236.36.78
sinatra_public_url = app-alb-1615642375.ap-southeast-2.elb.amazonaws.com
vpc_cidr = 172.16.0.0/16
vpc_id = vpc-ab79e4cc
```

use the sinatra_public_url to load the app on a browser and/or use the instance ssh ip along with the key (emailed), or use ```http://sinatra.olympushub.com```


Once done dont forget to destroy the stack and avoid charges on stale resources
```
cd sinatra/deploy
./destroy.sh 
```

### Assumptions

Anything in the terraform code can be parameterised. Any parameter can be put into the vars.tfvars and made to be reusable across multiple environments

Assuming there is no autoscaling, one instance was deployed

As requirements stated the app is listening on port 80 on webrick, Ideally I would have got webrick to listen on its default port and have the ALB relay traffic into it whilst listening on port 443 with a certificate issued/maintained by the ACM, and you'd need a domain

An AMI with ruby 2.3 installed has been shared publicly and is used during the deployment which is defined in the app.tf 

Access to the instances on port 22 are open to the public, However in an ideal scenario ssh access will be locked down to bastion/jump instances which are inturn locked down by source IP addresses,  and instance access would be managed by federated identity


### Design Choices and trade off's

Terraform was selected over other IaaC languages because of the fact that it is portable across other cloud providers and allows integration of other 3rd party providers like cloudflares.
Terraform also lets you plan the deployment which runs through the config files and then executes the actual deployment. The only trade off is that a change would require the entire stack to be redeployed, however following the concepts of immutable infrastructure this seems like a viable option.

Not using S3 buckets to store statefiles with dynamodb file locks - This implementation will ensure that the state files are well protected and preserved and the dynamodb table backend will ensure that only one execution of the terraform plans exist with file locks , I did implement something similar but removed it for simplicity



