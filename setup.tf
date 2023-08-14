provider "aws" {
  region = "us-east-1"
}

# retrieve all AZs available for the VPC in a specific region
data "aws_availability_zones" "azs" {
  state = "available"
}

# retrieve the VPC's main route table to modify
data "aws_route_table" "main_route_table" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc1.id]
  }
  filter {
    name   = "association.main"
    values = ["true"]
  }
}

# get Linux AMI ID using SSM parameter endpoint
data "aws_ssm_parameter" "ami-web" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# create VPC in us-east-1
resource "aws_vpc" "vpc1" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "tf-vpc"
  }
}

# create subnet in the 1st VPC AZ returned (element 0 in AZ list)
resource "aws_subnet" "sub1" {
  vpc_id            = aws_vpc.vpc1.id
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  cidr_block        = "10.0.1.0/24"
}

# create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id
}

# create a route table for internet access via IGW above
resource "aws_default_route_table" "route_internet" {
  default_route_table_id = data.aws_route_table.main_route_table.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "tf-default-route-table-to-internet"
  }
}

# create Security Group to allow n/w traffic on TCP/22 & TCP/80
resource "aws_security_group" "sg1" {
  name        = "sg1"
  description = "Allow TCP/80 & TCP/22"
  vpc_id      = aws_vpc.vpc1.id
  ingress {
    description = "allow inbound ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow inbound http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "allow outbound all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create key-pair to SSH into EC2 instance
resource "aws_key_pair" "key_web" {
  key_name   = "key-web"
  public_key = file("~/.ssh/id_rsa.pub")
}
