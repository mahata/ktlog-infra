resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = var.common_tags
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public["public_1"].id
  route_table_id = var.public_route_table_id
}

resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = var.common_tags
}

resource "aws_route_table" "private" {
  for_each = toset(["private_1", "private_2", "private_3"])

  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_id
  }
}

resource "aws_route_table_association" "private" {
  for_each = toset(["private_1", "private_2", "private_3"])

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
