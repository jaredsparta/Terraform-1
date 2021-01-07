# NAMES
variable "db_name" {
    description = "Name of the db"
}

variable "db_security_group_id" {
    description = "The SG ID for the db"
}

variable "aws_key_name" {
    description = "The name for the AWS key as found on AWS"
}

variable "instance_type" {
    description = "The instance type eg `t2.micro`"
}

variable "subnet_id" {
    description = "The ID for the subnet to associate it to"
}

variable "ami_id" {
    description = "The ID for the AMI it has"
}