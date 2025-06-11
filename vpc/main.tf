resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main-InternetGateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "rta_subnet1" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# resource "aws_subnet" "public_subnet_1" {
#   count = length(var.public_subnet_1)

#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = var.public_subnet_1[count.index]
#   availability_zone       = "us-east-1a"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "PublicSubnet-${count.index + 1}"
#   }
# }

# resource "aws_subnet" "public_subnet_2" {
#   count = length(var.public_subnet_2)

#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = var.public_subnet_2[count.index]
#   availability_zone       = "us-east-1b"
#   map_public_ip_on_launch = true
# }