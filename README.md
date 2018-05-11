### Deployment of Simple Sinatra app

## Technologies used 

Terraform
AWS
Shell scripting

## Prerequisites

Terraform - Version 0.11.7 from homebrew
AWS account - (Feel free to use mine, keys already defined )


## Steps to deploy

#Clone Repo
```
git clone https://github.com/niroliyanage/sinatra.git
```
#Configure AWS credentials to a profile (default)

Execute the following on a terminal
```
	cat << EOF | tee ~/.aws/config
	[default]
	aws_access_key_id = AKIAILUKB2YOG72SLINQ
	aws_secret_access_key = l6q6OkWaEDU3/Y0J9aTgsT/4mfnohLuTpmuDvB9o
	region = ap-southeast-2
	EOF
```
If its preferred that your own AWS account be used , it will make things easier as the account being used has Administrator  Privileges.

#Navigate to the deploy folder
```
cd sinatra/deploy
```
Run the terraform plan
```
./plan
```
Run the Terraform apply 
```
./apply
```
This will deploy a VPC, Subnets, Routing, Security groups along with access rules, an application load balancer and an ec2 instance where the sinatra app will get deployed when started. 

Once the Terraform apply completes you will see the output at the end similar to the following

```
instance ssh ip = 54.252.181.90
sinatra_public_url = internal-app-alb-98689535.ap-southeast-2.elb.amazonaws.com
vpc_cidr = 172.16.0.0/16
vpc_id = vpc-1226b475
```

use the sinatra_public_url to load the app on a browser and/or use the instance ssh ip along with the key (niro_cf_testing.pem).


Once done dont forget to destroy the stack and avoid charges on stale resources
```
cd sinatra/deploy
./destroy 
```

##Assumptions

Anything in the terraform code can be parameterised , it might appear to be a bespoke solution, however any parameter can be put into the vars.tfvars and made to be reusable across multiple environments





Design Choices and trade off's

Terraf

