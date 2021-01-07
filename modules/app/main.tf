# APP MODULE -- CREATES THE APP INSTANCE

# The app instance
resource "aws_instance" "nodejs_instance" {
    ami = var.ami_id
    subnet_id = var.subnet_id
    instance_type = var.instance_type
    associate_public_ip_address = true
    key_name = var.aws_key_name
    vpc_security_group_ids = [var.app_security_group_id]
    user_data = var.user_data
    tags = {
      "Name" = var.app_name
    }
}
