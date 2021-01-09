# PROVIDER
provider "aws" {
    region = "eu-west-1"
}

# Creates the VPC, subnets etc.
module "vpc_stuff" {
    source = "./modules/vpc-etc"

    # Common variables
    personal_ip = var.personal["ip"]

    # VPC variables
    vpc_name = "eng74-jared-terraform-vpc"
    vpc_cidr_block = var.cidr_blocks["vpc"]

    # IGW variables
    igw_name = "eng74-jared-terraform-IGW"

    # Route table variables
    public_route_table_name = "eng74-jared-terraform-route-public"
    private_route_table_name = "eng74-jared-terraform-route-private"

    # Security group variables
    app_security_group_name = "eng74.jared.SG.app.terraform"
    db_security_group_name = "eng74.jared.SG.db.terraform"

    # Network ACL variables
    public_nacl_name = "eng74-jared-terraform-public-nacl"
    private_nacl_name = "eng74-jared-terraform-private-nacl"

    # Subnet variables
    public_subnet_name = "eng74-jared-terraform-public"
    private_subnet_name = "eng74-jared-terraform-private"
    public_subnet_cidr_block = var.cidr_blocks["public_subnet"]
    private_subnet_cidr_block = var.cidr_blocks["private_subnet"]
}

# The db instance
module "db_instance" {
    source = "./modules/database"

    # Parameters to pass
    db_name = "eng74-jared-terraform-db"
    db_security_group_id = module.vpc_stuff.private_security_group_id
    aws_key_name = var.personal["key"]
    instance_type = "t2.micro"
    subnet_id = module.vpc_stuff.private_subnet_id
    ami_id = var.ami["db"]
}

# Auto scaling group -- max 2 instances, desired 2 instances, min 1 instance
module "autoscaling_group" {
    source = "./modules/auto-scaling"

    # Load balancer variables
    load_balancer_name = "eng74-jared-terraform-LB"
    load_balancer_type = "network"
    load_balancer_subnet_id = module.vpc_stuff.public_subnet_id

    # Target group variables
    target_group_name = "eng74-jared-terraform-TG"
    target_group_target_type = "instance"
    target_group_protocol = "TCP"
    target_group_port = 80
    target_group_vpc_id = module.vpc_stuff.vpc_id

    # Launch Configuration variables
    launch_configuration_name = "eng74-jared-terraform-LC"
    launch_configuration_ami_id = var.ami["app"]
    launch_configuration_instance_type = "t2.micro"
    launch_configuration_security_group_id = module.vpc_stuff.public_security_group_id
    launch_configuration_key_name = var.personal["key"]
    launch_configuration_user_data = templatefile("./template.tpl", {db-ip = module.db_instance.db_private_ip})

    # Auto-scaling group variables
    autoscaling_group_name = "eng74-jared-terraform-ASG"
    autoscaling_group_max_size = 2
    autoscaling_group_min_size = 1
    autoscaling_group_desired_size = 2
    autoscaling_group_subnet_id = module.vpc_stuff.public_subnet_id
    autoscaling_group_instance_names = "eng74-jared-terraform-ASG-min1-max2-des2"
}

output "dns_of_load_balancer" {
    value = module.autoscaling_group.load_balancer_dns_name
}