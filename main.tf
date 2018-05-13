
provider "aws" {
    profile = "terraform-network"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "ap-southeast-2"
}

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}
