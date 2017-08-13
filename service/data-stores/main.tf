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
}