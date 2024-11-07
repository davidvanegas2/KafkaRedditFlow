resource "aws_vpc" "msk_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "msk_vpc"
  }
}

data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_subnet" "msk_subnet_1" {
  vpc_id            = aws_vpc.msk_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
    Name = "msk_subnet_1"
  }
}

resource "aws_subnet" "msk_subnet_2" {
  vpc_id            = aws_vpc.msk_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
    Name = "msk_subnet_2"
  }
}

resource "aws_security_group" "msk_sg" {
  vpc_id      = aws_vpc.msk_vpc.id
  description = "Allow MSK Traffic"

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For demo purposes, allows traffic from anywhere
  }

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
