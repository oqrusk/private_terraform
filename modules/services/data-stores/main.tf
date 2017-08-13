terraform {
  backend "s3" {
    bucket = "oqrusk-test-terraform"
    key    = "data-stores/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "${terraform.workspace == "test" ? "us-east-1" : "ap-north-east-1"}"
}

resource "aws_db_instance" "example" {
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "${var.db_name}"
  username          = "${var.db_user}"
  password          = "${var.db_password}"

//  db_subnet_group_name = "${aws_db_subnet_group.db-subnet.name}"
  vpc_security_group_ids = ["${aws_security_group.db-instance.id}"]
}

//resource "aws_db_subnet_group" "db-subnet" {
//  name = "test-db-subnet"
//  description = "test db subnet"
//  subnet_ids = ["${aws_subnet.private.0.id}", "${aws_subnet.private.1.id}"]
//}

resource "aws_security_group" "db-instance" {
  name = "mysql"
  description = "for mysql"
//  vpc_id = "${aws_vpc.test.id}"
  ingress {
    from_port = 3306
    to_port =3306
    protocol = "tcp"
    security_groups = ["${data.terraform_remote_state.webservers.instance_sg}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "terraform_remote_state" "webservers" {
  backend = "s3"

  config {
    bucket = "oqrusk-test-terraform"
    key    = "env:/${terraform.workspace}/webservers/terraform.tfstate"
    region = "us-east-1"
  }
}