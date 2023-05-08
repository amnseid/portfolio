#datasource for AMI
data "aws_ami" "server_ami" {
  most_recent = true
  owners      = [""]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}