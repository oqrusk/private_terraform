terraform {
  backend "s3" {
    bucket = "oqrusk-test-terraform"
    key    = "webservers/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "${terraform.workspace == "test" ? "us-east-1" : "ap-north-east-1"}"
}

resource "aws_launch_configuration" "example" {
  image_id      = "${var.base_ami}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.instance.id}"]

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {

  template = "${file("user-data.sh")}"

  vars {
    server_port = "${var.server_port}"
    db_address  = "${data.terraform_remote_state.db.address}"
    db_port     = "${data.terraform_remote_state.db.port}"
    db_name     = "${data.terraform_remote_state.db.name}"
    db_user     = "${data.terraform_remote_state.db.user}"
    db_password = "${data.terraform_remote_state.db.password}"
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  load_balancers    = ["${aws_elb.example.name}"]
  health_check_type = "ELB"

  max_size = 5
  min_size = 2

  tag {
    key = "Name"
    propagate_at_launch = false
    value = "terraform-asg-sample"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_elb" "example" {
  name = "terraform-asg-example"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port = "${var.server_port}"
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    interval = 30
    target = "HTTP:${var.server_port}/"
    timeout = 3
    unhealthy_threshold = 2
  }

}

resource "aws_security_group" "elb" {
  name = "terraform-example-elb"

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "all" {
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config {
    bucket = "oqrusk-test-terraform"
    key    = "env:/${terraform.workspace}/data-stores/terraform.tfstate"
    region = "us-east-1"
  }
}