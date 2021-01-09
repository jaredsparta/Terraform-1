# Creates a load balancer, a target group, a launch configuration (template) 
# and an auto scaling group

resource "aws_lb" "load_balancer" {
    name = var.load_balancer_name
    load_balancer_type = "network"
    subnets = [var.load_balancer_subnet_id]

}

resource "aws_lb_target_group" "target_group" {
    name = var.target_group_name
    target_type = var.target_group_target_type
    protocol = var.target_group_protocol
    port = var.target_group_port
    vpc_id = var.target_group_vpc_id
}

resource "aws_launch_configuration" "launch_configuration" {
    name = var.launch_configuration_name
    image_id = var.launch_configuration_ami_id
    instance_type = var.launch_configuration_instance_type
    security_groups = [ var.launch_configuration_security_group_id ]
    key_name = var.launch_configuration_key_name
    associate_public_ip_address = false
    user_data = var.aws_launch_configuration.user_data
}

resource "aws_autoscaling_group" "autoscaling_group" {
    name = var.autoscaling_group_name
    max_size = var.autoscaling_group_max_size
    min_size = var.autoscaling_group_min_size
    desired_capacity = var.autoscaling_group_desired_size
    launch_configuration = aws_launch_configuration.launch_configuration.name
    vpc_zone_identifier = [ var.autoscaling_group_subnet_id ]
    tag {
        key = "Name"
        value = var.autoscaling_group_instance_names
        propagate_at_launch = true
    }
}