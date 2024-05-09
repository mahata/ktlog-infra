resource "aws_security_group" "eice_ssh" {
  name        = "${var.project}-${var.environment}-eice"
  description = "Security Group for EC2 Instance Connect Endpoint"
  vpc_id      = var.vpc_id

  tags = var.common_tags

  egress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.base_cidr_block]
  }
}

resource "aws_ec2_instance_connect_endpoint" "eice_ssh" {
  subnet_id          = var.public_subnet_ids[0]
  security_group_ids = [aws_security_group.eice_ssh.id]

  tags = var.common_tags
}
