# PROVIDER
provider "aws" {
    region = "eu-west-1"
}

# Creates the network topology etc.
module "vpc_stuff" {
    source = "./modules/vpc-etc"

    # Parameters to pass
    # Names of infrastructure objects
    app_security_group_name = "eng74.jared.SG.app.terraform"
    db_security_group_name = "eng74.jared.SG.db.terraform"
    vpc_name = "eng74-jared-terraform-vpc"
    public_subnet_name = "eng74-jared-terraform-public"
    private_subnet_name = "eng74-jared-terraform-private"
    igw_name = "eng74-jared-terraform-IGW"
    public_route_table_name = "eng74-jared-terraform-route-public"
    private_route_table_name = "eng74-jared-terraform-route-private"

    aws_key = var.personal["key"]
    vpc_cidr_block = var.cidr_blocks["vpc"]
    public_subnet_cidr_block = var.cidr_blocks["public_subnet"]
    private_subnet_cidr_block = var.cidr_blocks["private_subnet"]
    personal_ip = var.personal["ip"]
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

# The app instance
module "app_instance" {
    source = "./modules/app"

    # Parameters to pass
    app_name = "eng74-jared-terraform-app"
    app_security_group_id = module.vpc_stuff.public_security_group_id
    aws_key_name = var.personal["key"]
    instance_type = "t2.micro"
    subnet_id = module.vpc_stuff.public_subnet_id
    ami_id = var.ami["app"]
    user_data = templatefile("./template.tpl", {db-ip = module.db_instance.db_private_ip})
}

output "app_ip" {
    value  = module.app_instance.app_public_ip
}
