variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}

variable "base_ami" {
  description = "The id of AMI for ASG"
  default = "ami-40d28157"
}
variable "instance_type" {
  description = "instance type of ASG"
  default = "t2.micro"
}