
# VPC and subnets

resource "aws_vpc" "vpc" {
    cidr_block = "172.16.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "Sinatra vpc"
    }
}

output "vpc_id" {
    value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr" {
    value = "${aws_vpc.vpc.cidr_block}"
}

### Subnets

resource "aws_subnet" "app" {
    count = "${length(var.availability_zones[var.region])}"
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, 6, count.index + 10)}"
    map_public_ip_on_launch = true
    availability_zone = "${element(var.availability_zones[var.region], count.index)}"

    tags = {
        Name = "sinatra subnet"
    }
}


resource "aws_route_table_association" "app_subnet_associations" {
    count = "${length(var.availability_zones[var.region])}"
    subnet_id = "${aws_subnet.app.*.id[count.index]}"
    route_table_id = "${aws_vpc.vpc.main_route_table_id}"

    depends_on = ["aws_subnet.app"]
}


## routing ###

resource "aws_internet_gateway" "gateway" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "sinatra internet gateway"
    }
}

resource "aws_route" "main_route" {
    route_table_id = "${aws_vpc.vpc.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway.id}"
}
