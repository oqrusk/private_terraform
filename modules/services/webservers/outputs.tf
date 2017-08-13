output "elb_dns_name" {
  value = "${aws_elb.example.dns_name}"
}

output "instance_sg" {
  value = "${aws_security_group.instance.id}"
}
