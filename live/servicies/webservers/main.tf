provider "aws" {
  region = "us-east-1"
}

module "webservers" {
  source = "../../../modules/services/webservers"


  cluster_name = "webservers-${terraform.workspace}"
  db_remote_state_bucket = "oqrusk-test-terraform"
  db_remote_state_key = "env:/${terraform.workspace}/data-stores/terraform.tfstate"


  max_size = "${terraform.workspace == "staging" ? "2" : terraform.workspace == "production" ? "5": "2"}"
  min_size = "${terraform.workspace == "test" ? "1" : "2"}"
}