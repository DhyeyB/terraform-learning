# creating vpc
resource "aws_vpc" "dhyey_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Dhyey VPC"
  }
}

# creating public subnet
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.dhyey_vpc.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Public subnet ${count.index + 1}"
  }
}

# creating private subnet
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.dhyey_vpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Private subnet ${count.index + 1}"
  }
}

# creating internet gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.dhyey_vpc.id

  tags = {
    Name = "Dhyey VPC IG"
  }
}

# creating reoute table for public subnet
resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.dhyey_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "Route Table"
  }
}

# associating public route table with public subnets
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.rt-public.id
}

# creating elastic ip for nat gateway
resource "aws_eip" "ng_eip" {
  count  = length(var.private_subnet_cidrs)
  domain = "vpc"
}

# creating nat gateway
resource "aws_nat_gateway" "ng" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = element(aws_eip.ng_eip[*].id, count.index)
  subnet_id     = element(aws_subnet.public_subnet[*].id, count.index)

  tags = {
    Name = " Nat gateway"
  }
}


# creating route table for private subnet
resource "aws_route_table" "rt-private" {
  vpc_id = aws_vpc.dhyey_vpc.id
  count  = length(var.public_subnet_cidrs)

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.ng[*].id, count.index)
  }
}

# associating private route table with private subnet
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = element(aws_route_table.rt-private[*].id, count.index)
}