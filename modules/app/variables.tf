# APP VARIABLES
variable "app_name" {
    description = "Name of the app"
}

variable "app_security_group_id" {
    description = "The SG ID for the app"
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

variable "user_data" {
    description = "AWS user data to pass to the app instance"
}
