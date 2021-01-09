# VPC - checked
resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr_block
    
    tags = {
        "Name" = var.vpc_name
    }
}

# IGW FOR PUBLIC SUBNET - checked
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = var.igw_name
    }
}


### ROUTE TABLES
# ROUTE TABLE FOR PUBLIC SUBNET -- checked
resource "aws_route_table" "route_table_public" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    tags = {
        Name = var.public_route_table_name
    }
}

# ROUTE TABLE ASSOCIATION FOR PUBLIC -- nothing to check
resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table_public.id
}

# ROUTE TABLE ASSOCIATION FOR PRIVATE -- nothing to check
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.route_table_private.id
}

# ROUTE TABLE FOR PRIVATE SUBNET -- checked
resource "aws_route_table" "route_table_private" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = var.private_route_table_name
    }
}


### SECURITY GROUPS
# APP SECURITY GROUP -- checked
resource "aws_security_group" "appSG" {
    name = var.app_security_group_name
    description = "the security group for the app via terraform"
    vpc_id = aws_vpc.vpc.id

    ingress {
        description = "port 80 access anywhere"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "port 22 from home"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ var.personal_ip ]
    }

    egress {
        description = "outbound with no restrictions"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# DB SECURITY GROUP -- checked
resource "aws_security_group" "dbSG" {
    name = var.db_security_group_name
    description = "allows access to app from port 80 anywhere"
    vpc_id = aws_vpc.vpc.id

    ingress {
        description = "port 27017 access from app"
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        security_groups = [ aws_security_group.appSG.id ]
    }

    ingress {
        description = "port 22 from home"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ var.personal_ip ]
    }

    egress {
        description = "outbound with no restrictions"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}

### NACLs
# PUBLIC NACL -- checked
resource "aws_network_acl" "public_nacl" {
    vpc_id = aws_vpc.vpc.id
    subnet_ids = [aws_subnet.public_subnet.id]
    tags = {
        "Name" = var.public_nacl_name
    }

    # Ephemeral ports outbound for everywhere
    egress {
        protocol = "tcp"
        rule_no = 110
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 80
        to_port = 80
    }

    # Port 443 outbound for everywhere
    egress {
        protocol = "tcp"
        rule_no = 130
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 443
        to_port = 443
    }

    # Ephemeral ports outbound open for everywhere
    egress {
        protocol = "tcp"
        rule_no = 140
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 1024
        to_port = 65535
    }

    # Port 80 open for everywhere
    ingress {
        protocol = "tcp"
        rule_no = 110
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 80
        to_port = 80
    }

    # Port 22 for home ip
    ingress {
        protocol = "tcp"
        rule_no = 120
        action = "allow"
        cidr_block = var.personal_ip
        from_port = 22
        to_port = 22
    }

    # Port 443 for everywhere
    ingress {
        protocol = "tcp"
        rule_no = 130
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 443
        to_port = 443
    }

    # Ephemeral ports open for everywhere
    ingress {
        protocol = "tcp"
        rule_no = 140
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 1024
        to_port = 65535
    }
    
}

# PRIVATE NACL -- checked
resource "aws_network_acl" "private_nacl" {
    vpc_id = aws_vpc.vpc.id
    subnet_ids = [aws_subnet.private_subnet.id]
    tags = {
        "Name" = var.private_nacl_name
    }

    # Port 80 outbound to public subnet
    egress {
        protocol = "tcp"
        rule_no = 110
        action = "allow"
        cidr_block = var.public_subnet_cidr_block
        from_port = 0
        to_port = 65535
    }

    # Port 27017 outbound to public subnet
    ingress {
        protocol = "tcp"
        rule_no = 110
        action = "allow"
        cidr_block = var.public_subnet_cidr_block
        from_port = 27017
        to_port = 27017
    }

    # Port 22 for home ip
    ingress {
        protocol = "tcp"
        rule_no = 120
        action = "allow"
        cidr_block = var.personal_ip
        from_port = 22
        to_port = 22
    }
    
}


### SUBNETS
# PUBLIC SUBNET -- checked
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.public_subnet_cidr_block

    tags = {
        Name = var.public_subnet_name
    }
}

# PRIVATE SUBNET -- checked
resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.private_subnet_cidr_block

    tags = {
        Name = var.private_subnet_name
    }
}