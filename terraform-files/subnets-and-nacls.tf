# PUBLIC SUBNET
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.cidr_blocks["public_subnet"]

    tags = {
        Name = "eng74-jared-terraform-public"
    }
}

# PRIVATE SUBNET
resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.cidr_blocks["private_subnet"]

    tags = {
        Name = "eng74-jared-terraform-private"
    }
}

# PUBLIC NACL
resource "aws_network_acl" "public_nacl" {
    vpc_id = aws_vpc.vpc.id
    subnet_ids = [aws_subnet.public_subnet.id]

    # Port 80 outbound for everywhere
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
        cidr_block = var.personal["ip"]
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

# PRIVATE NACL
resource "aws_network_acl" "private_nacl" {
    vpc_id = aws_vpc.vpc.id
    subnet_ids = [aws_subnet.private_subnet.id]

    # Port 80 outbound to public subnet
    egress {
        protocol = "tcp"
        rule_no = 110
        action = "allow"
        cidr_block = var.cidr_blocks["public_subnet"]
        from_port = 0
        to_port = 65535
    }

    # Port 27017 outbound to public subnet
    ingress {
        protocol = "tcp"
        rule_no = 110
        action = "allow"
        cidr_block = var.cidr_blocks["public_subnet"]
        from_port = 27017
        to_port = 27017
    }

    # Port 22 for home ip
    ingress {
        protocol = "tcp"
        rule_no = 120
        action = "allow"
        cidr_block = var.personal["ip"]
        from_port = 22
        to_port = 22
    }
    
}