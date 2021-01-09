# COMMON VARIABLES

# USED IN SEC GROUPS, NETWORK ACLS
variable "personal_ip" {
    type = string
    description = "Pass the value of your personal IP, ensure it ends in /32"
}


# VPC VARIABLES
variable "vpc_name" {
    type = string
    description = "Name of the VPC"
}

variable "vpc_cidr_block" {
    type = string
    description = "The CIDR block for your VPC"
}

# IGW VARIABLES
variable "igw_name" {
    type = string
    description = "Name of the IGW"
}

# PUBLIC ROUTE TABLE VARIABLES
variable "public_route_table_name" {
    type = string
    description = "Name of pub route table"
}

# PRIVATE ROUTE TABLE VARIABLES
variable "private_route_table_name" {
    type = string
    description = "Name of priv route table"
}

# APP SECURITY GROUP VARIABLES
variable "app_security_group_name" {
    type = string
    description = "Name of the SG for the app"
}

# DB SECURITY GROUP VARIABLES
variable "db_security_group_name" {
    type = string
    description = "Name of the SG for the db"
}

# PUBLIC NACL VARIABLES
variable "public_nacl_name" {
    description = "Name of network acl for public subnet"
}

# PRIVATE NACL VARIABLES
variable "private_nacl_name" {
    description = "Name of network acl for private subnet"
}

# PUBLIC SUBNET VARIABLES
variable "public_subnet_name" {
    type = string
    description = "Name of the public subnet"
}

variable "public_subnet_cidr_block" {
    type = string
    description = "The CIDR block for the pub subnet"
}


# PRIVATE SUBNET VARIABLES
variable "private_subnet_name" {
    type = string
    description = "Name of the private subnet"
}

variable "private_subnet_cidr_block" {
    type = string
    description = "The CIDR block for the priv subnet"
}

