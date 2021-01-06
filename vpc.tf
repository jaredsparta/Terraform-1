resource "aws_vpc" "vpc" {
    cidr_block = "120.13.0.0/16"
    tags = {
        "Name" = "eng74-jared-terraform-vpc"
    }
}

resource "aws_subnet" "subnet" {
    
}