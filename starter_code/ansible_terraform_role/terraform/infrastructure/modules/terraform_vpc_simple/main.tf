provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name    = "${var.project_name}_vpc"
    Project = var.project_name
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project_name}_sn"
    Project = var.project_name
  }

}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}_gw"
    Project = var.project_name
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.default_route
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}_rt"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "web_rt_assoc_1" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}
