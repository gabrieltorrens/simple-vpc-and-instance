# Configure the AWS Provider
provider "aws" {
  region = var.region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}_vpc"
  }
}

resource "aws_security_group" "my_sg" {
  name        = "${var.prefix}_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "my_subnet_public" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}_public_subnet"
  }
}


resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.prefix}_igw"
  }

}

resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "${var.prefix}_rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet_public.id
  route_table_id = aws_route_table.my_rt.id
}

resource "aws_instance" "my_instance" {
  ami           = var.ami_id # Replace with a valid AMI for your region
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.my_subnet_public.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  tags = {
    Name = "my_instance"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              EOF
}
