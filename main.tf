# Which cloud provider are we using? Our AMI's are on AWS
# The AMI's are region-specific so we also need to specify it
provider "aws" {
    region = "eu-west-1"
}


resource "aws_security_group" "appSG" {
    name = "eng74.jared.SG.app.terraform"
    description = "allows access to app from port 80 anywhere"

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
        cidr_blocks = ["95.147.237.10/32"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_security_group" "dbSG" {
    name = "eng74.jared.SG.db.terraform"
    description = "allows access to app from port 80 anywhere"

    ingress {
        description = "port 27017 access from app"
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "port 22 from home"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.appSG.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_instance" "nodejs_instance" {
    ami = var.ami["app"]
    instance_type = "t2.micro"
    associate_public_ip_address = true
    key_name = var.keys["jared"]
    vpc_security_group_ids = [ aws_security_group.appSG.id ]
    tags = {
      "Name" = "eng74-jared-terraform-app"
    }
}


resource "aws_instance" "mongodb_instance" {
    ami = var.ami["db"]
    instance_type = "t2.micro"
    associate_public_ip_address = true
    key_name = var.keys["jared"]
    vpc_security_group_ids = [ aws_security_group.dbSG.id ]
    tags = {
      "Name" = "eng74-jared-terraform-db"
    }
}
