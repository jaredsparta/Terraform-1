resource "aws_security_group" "appSG" {
    name = "eng74.jared.SG.app.terraform"
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
        cidr_blocks = [ var.personal["ip"] ]
    }

    egress {
        description = "outbound with no restrictions"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_security_group" "dbSG" {
    name = "eng74.jared.SG.db.terraform"
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
        cidr_blocks = [ var.personal["ip"] ]
    }

    egress {
        description = "outbound with no restrictions"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}