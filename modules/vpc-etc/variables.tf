# NAMES OF INFRASTRUCTURE
variable "app_security_group_name" {
    type = string
    description = "Name of the SG for the app"
}

variable "db_security_group_name" {
    type = string
    description = "Name of the SG for the db"
}

variable "vpc_name" {
    type = string
    description = "Name of the VPC"
}

variable "public_subnet_name" {
    type = string
    description = "Name of the public subnet"
}

variable "private_subnet_name" {
    type = string
    description = "Name of the private subnet"
}

variable "igw_name" {
    type = string
    description = "Name of the IGW"
}

variable "public_route_table_name" {
    type = string
    description = "Name of pub route table"
}

variable "private_route_table_name" {
    type = string
    description = "Name of priv route table"
}

# AWS KEY NAME
variable "aws_key" {
    type = string
    description = "The name of the AWS key to use for the instance, as found on AWS key pairs"
}

# IP ADDRESSES
variable "vpc_cidr_block" {
    type = string
    description = "The CIDR block for your VPC"
}

variable "public_subnet_cidr_block" {
    type = string
    description = "The CIDR block for the pub subnet"
}

variable "private_subnet_cidr_block" {
    type = string
    description = "The CIDR block for the priv subnet"
}

variable "personal_ip" {
    type = string
    description = "Pass the value of your personal IP, ensure it ends in /32"
}
