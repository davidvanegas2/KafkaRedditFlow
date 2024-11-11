resource "aws_vpc" "msk_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

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

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.msk_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.msk_vpc.id

  tags = {
    Name = "msk_igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.msk_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}
