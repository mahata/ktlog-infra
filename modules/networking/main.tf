resource "aws_vpc" "main" {
  cidr_block       = var.base_cidr_block
  instance_tenancy = "default"

  tags = var.common_tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = var.common_tags
}

resource "aws_route_table" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = var.common_tags
}

resource "aws_eip" "main_ngw" {
  domain = "vpc"
}

resource "aws_nat_gateway" "public_1" {
  subnet_id     = var.public_subnet_ids[0]
  allocation_id = aws_eip.main_ngw.id

  tags = var.common_tags
}
