resource "aws_security_group" "ec2_public_sg" {
  vpc_id      = aws_vpc.msk_vpc.id
  description = "Allow EC2 Traffic"

  ingress {
    description = "Allow SSH traffic from my local IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2 Public SG"
  }
}

resource "aws_security_group" "msk_sg" {
  vpc_id      = aws_vpc.msk_vpc.id
  description = "Allow MSK Traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "msk_sg"
  }
}

resource "aws_security_group_rule" "ec2_to_msk" {
  type                     = "ingress"
  description              = "Allow Kafka communication with MSK"
  from_port                = 9094
  to_port                  = 9094
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2_public_sg.id
  source_security_group_id = aws_security_group.msk_sg.id
}

resource "aws_security_group_rule" "msk_to_ec2" {
  type                     = "ingress"
  description              = "Allow Kafka communication with EC2"
  from_port                = 9094
  to_port                  = 9094
  protocol                 = "tcp"
  security_group_id        = aws_security_group.msk_sg.id
  source_security_group_id = aws_security_group.ec2_public_sg.id
}
