
###Security Groups####

resource "aws_security_group" "app_security_group" {
    name                   = "app-security-group"
    description            = "app security group"
    vpc_id                 = "${aws_vpc.vpc.id}"
}

resource "aws_security_group" "app_alb_security_group" {
    name                     = "app-alb-security-group"
    description              = "app security group"
    vpc_id                 = "${aws_vpc.vpc.id}"
}


resource "aws_security_group_rule" "app_ssh_ingress" {
    security_group_id        = "${aws_security_group.app_security_group.id}"
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "app_alb_http_ingress" {
    security_group_id        = "${aws_security_group.app_alb_security_group.id}"
    type                     = "ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_egress" {
    security_group_id        = "${aws_security_group.app_security_group.id}"
    type                     = "egress"
    from_port                = 0
    to_port                  = 65535
    protocol                 = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_to_app_ingress" {
    security_group_id        = "${aws_security_group.app_security_group.id}"
    type                     = "ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = "${aws_security_group.app_alb_security_group.id}"
}

resource "aws_security_group_rule" "alb_egress" {
    security_group_id        = "${aws_security_group.app_alb_security_group.id}"
    type                     = "egress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = "${aws_security_group.app_security_group.id}"
}


## Userdata ##

data "template_file" "app_userdata" {
  template        = "${file("${path.module}/templates/app_userdata.sh")}"
  }


data "template_cloudinit_config" "app_userdata" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.app_userdata.rendered}"
  }
}
#######


######## Sinatra App ##########################

resource "aws_lb" "app_alb" {
    name            = "app-alb"
    security_groups = ["${aws_security_group.app_alb_security_group.id}"]
    subnets         = ["${aws_subnet.app.*.id}"]
    tags {
        Name        = "app alb"
    }
    lifecycle { create_before_destroy = true }

    depends_on = ["aws_security_group.app_security_group"]
}


output "sinatra_public_url" {

	value = "${aws_lb.app_alb.dns_name}"
}

resource "aws_lb_target_group" "app" {
    name                    = "app-tg"
    port                    = 80
    protocol                = "HTTP"
    vpc_id                  = "${aws_vpc.vpc.id}"
    health_check {
        protocol            = "HTTP"
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = "3"
        unhealthy_threshold = "2"
        timeout             = "10"
        interval            = "30"
        matcher             = "200"     
    }
    lifecycle { create_before_destroy = true }
}

resource "aws_alb_listener" "app_frontend" {
    load_balancer_arn    = "${aws_lb.app_alb.arn}"
    port                 = "80"
    protocol             = "HTTP"
    default_action {
        target_group_arn = "${aws_lb_target_group.app.arn}"
        type             = "forward"
    }
    lifecycle { create_before_destroy = true }

    depends_on = ["aws_lb_target_group.app"]
}


resource "aws_instance" "sinatra_app" {
	ami                        = "ami-b9f026db"
	instance_type 			   = "t2.micro"
	availability_zone			= "ap-southeast-2a"
	subnet_id					= "${aws_subnet.app.*.id[count.index]}"
    associate_public_ip_address = "true"
    security_groups             = ["${aws_security_group.app_security_group.id}"]
    user_data                   = "${data.template_cloudinit_config.app_userdata.rendered}"
    key_name                    = "${var.key_pair_name}"


	tags {
    Name = "Sinatra app"
  }
    lifecycle { create_before_destroy = true }

}

output "instance ssh ip" {
	
	value = "${aws_instance.sinatra_app.public_ip}"
}

resource "aws_lb_target_group_attachment" "sinatra_attach" {
  target_group_arn = "${aws_lb_target_group.app.arn}"
  target_id        = "${aws_instance.sinatra_app.id}"
  port             = 80


}


resource "cloudflare_record" "sinatra_cname" {
  domain = "olympushub.com"
  name   = "sinatra"
  value  = "${aws_lb.app_alb.dns_name}"
  type   = "CNAME"
  ttl    = "1"
}
