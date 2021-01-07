variable "instance_types" {
    type = map
    default = {
        "app" = "t2.micro"
        "db" = "t2.micro"
    }
}

variable "cidr_blocks" {
    type = map
    default = {
        "vpc" = "120.13.0.0/16"
        "public_subnet" = "120.13.1.0/24"
        "private_subnet" = "120.13.2.0/24"
    }
}