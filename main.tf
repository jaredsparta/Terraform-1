# Uses the vpc-etc module to create the VPC etc.

# PROVIDER
provider "aws" {
    region = "eu-west-1"
}

module "vpc_stuff" {
    source = "./modules/vpc-etc"

    # Defines the variables for the VPC names etc. that the module uses
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

# The database instance
resource "aws_instance" "mongodb_instance" {
    ami = var.ami["db"]
    subnet_id = module.vpc_stuff.private_subnet_id
    instance_type = var.instance_types["db"]
    associate_public_ip_address = true
    key_name = var.personal["key"]
    vpc_security_group_ids = [module.vpc_stuff.private_security_group_id]
    tags = {
      "Name" = "eng74-jared-terraform-db"
    }
}

# The app instance
resource "aws_instance" "nodejs_instance" {
    ami = var.ami["app"]
    subnet_id = module.vpc_stuff.public_subnet_id
    instance_type = var.instance_types["app"]
    associate_public_ip_address = true
    key_name = var.personal["key"]
    vpc_security_group_ids = [module.vpc_stuff.public_security_group_id]
    user_data = templatefile("./template.tpl", { db-ip = aws_instance.mongodb_instance.private_ip })
    tags = {
      "Name" = "eng74-jared-terraform-app"
    }
}

output "app_ip" {
    value  = aws_instance.nodejs_instance.public_ip
}