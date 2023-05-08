# Create a VPC
resource "aws_vpc" "default_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "dev"
  }
}

# Create a subnet
resource "aws_subnet" "default_subnet" {
  vpc_id                  = aws_vpc.default_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "dev_public"
  }
}

# Create a internet gateway
resource "aws_internet_gateway" "default_gw" {
  vpc_id = aws_vpc.default_vpc.id

  tags = {
    Name = "dev_gw"
  }
}

# Create a route table
resource "aws_route_table" "default_rt" {
  vpc_id = aws_vpc.default_vpc.id

  tags = {
    name = "dev_rt"
  }
}

## Create a route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.default_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default_gw.id
}

#create subnet association with route table
resource "aws_route_table_association" "default_ass" {
  subnet_id      = aws_subnet.default_subnet.id
  route_table_id = aws_route_table.default_rt.id
}

#creates security groups
resource "aws_security_group" "default_sg" {
  name        = "dev_sg"
  description = "dev security groups"
  vpc_id      = aws_vpc.default_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#creates key pair resource
resource "aws_key_pair" "devkey_auth" {
  key_name   = "devkey"
  public_key = file("C:/Users/amin/.ssh/devkey.pub")
}
# provisions an instance
resource "aws_instance" "default_instance" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.devkey_auth.id
  vpc_security_group_ids = [aws_security_group.default_sg.id]
  subnet_id              = aws_subnet.default_subnet.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    name = "dev_instance"
  }
  #Deploys an instance and Replace the default_instance 
  provisioner "local-exec" {
    command = templatefile("ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/devkey"
    })
    interpreter = ["Powershell", "-Command"]
  }
}



