# VPC
resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_blocks["vpc"]
    
    tags = {
        "Name" = "eng74-jared-terraform-vpc"
    }
}

# IGW FOR PUBLIC SUBNET
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "eng74-jared-terraform-IGW"
    }
}

# ROUTE TABLE FOR PUBLIC SUBNET
resource "aws_route_table" "route_table_public" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    tags = {
        Name = "eng74-jared-terraform-route-public"
    }
}

# ROUTE TABLE FOR PRIVATE SUBNET
resource "aws_route_table" "route_table_private" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "eng74-jared-terraform-route-private"
    }
}

# ROUTE TABLE ASSOCIATION FOR PUBLIC
resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table_public.id
}

# ROUTE TABLE ASSOCIATION FOR PRIVATE
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.route_table_private.id
}