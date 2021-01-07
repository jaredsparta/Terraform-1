# DB MODULE -- CREATES THE DATABASE INSTANCE

# The database instance
resource "aws_instance" "mongodb_instance" {
    ami = var.ami_id
    subnet_id = var.subnet_id
    instance_type = var.instance_type
    associate_public_ip_address = true
    key_name = var.aws_key_name
    vpc_security_group_ids = [var.db_security_group_id]
    tags = {
      "Name" = var.db_name
    }
}