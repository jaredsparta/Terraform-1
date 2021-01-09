# LOAD BALANCER VARIABLES
variable "load_balancer_name" {}

variable "load_balancer_type" {
    default = "network"
}

variable "load_balancer_subnet_id" {}

# TARGET GROUP VARIABLES
variable "target_group_name" {}

variable "target_group_target_type" {
    default = "instance"
}

variable "target_group_protocol" {
    default = "TCP"
}

variable "target_group_port" {
    default = 80
}

variable "target_group_vpc_id" {}

# LAUNCH CONFIGURATION VARIABLES
variable "launch_configuration_name" {}

variable "launch_configuration_ami_id" {}

variable "launch_configuration_instance_type" {
    default = "t2.micro"
}

variable "launch_configuration_security_group_id" {}

variable "launch_configuration_key_name" {}

variable "launch_configuration_user_data" {
    default = ""
}

# AUTOSCALING GROUP VARIABLES
variable "autoscaling_group_name" {}

variable "autoscaling_group_max_size" {
    default = 2
}

variable "autoscaling_group_min_size" {
    default = 1
}

variable "autoscaling_group_desired_size" {
    default = 2
}

variable "autoscaling_group_subnet_id" {}

variable "autoscaling_group_instance_names" {}
