terraform {
 backend "s3" {
 encrypt = true
 bucket = "mystuff-niro"
 region = "ap-southeast-2"
 key = "sinatra/statefile"
 profile = "default"
 }
}


provider "aws" {
    profile = "terraform-network"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "ap-southeast-2"
}


