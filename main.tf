resource "aws_security_group" "appSG" {
    name = "eng74.jared.SG.app.terraform"
    description = "the security group for the app via terraform"

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


resource "aws_instance" "mongodb_instance" {
    ami = var.ami["db"]
    instance_type = "t2.micro"
    associate_public_ip_address = true
    key_name = var.personal["key"]
    vpc_security_group_ids = [ aws_security_group.dbSG.id ]
    tags = {
      "Name" = "eng74-jared-terraform-db"
    }
}


resource "aws_instance" "nodejs_instance" {
    ami = var.ami["app"]
    instance_type = "t2.micro"
    associate_public_ip_address = true
    key_name = var.personal["key"]
    vpc_security_group_ids = [ aws_security_group.appSG.id ]
    user_data = <<-EOF
        #!/bin/bash
        echo "export DB_HOST=${aws_instance.mongodb_instance.private_ip}" >> /home/ubuntu/.bashrc
        export DB_HOST=${aws_instance.mongodb_instance.private_ip}
        source /home/ubuntu/.bashrc
        cd /home/ubuntu/app
        pm2 start app.js --update-env
        pm2 restart app.js --update-env
        EOF
    tags = {
      "Name" = "eng74-jared-terraform-app"
    }
}
