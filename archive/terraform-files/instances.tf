# Will declare the actual EC2 instances

# The database instance
resource "aws_instance" "mongodb_instance" {
    ami = var.ami["db"]
    subnet_id = aws_subnet.private_subnet.id
    instance_type = var.instance_types["db"]
    associate_public_ip_address = true
    key_name = var.personal["key"]
    vpc_security_group_ids = [aws_security_group.dbSG.id]
    tags = {
      "Name" = "eng74-jared-terraform-db"
    }
}

# The app instance
resource "aws_instance" "nodejs_instance" {
    ami = var.ami["app"]
    subnet_id = aws_subnet.public_subnet.id
    instance_type = var.instance_types["app"]
    associate_public_ip_address = true
    key_name = var.personal["key"]
    vpc_security_group_ids = [aws_security_group.appSG.id]
    user_data = templatefile("./template.tpl", { db-ip = aws_instance.mongodb_instance.private_ip })
    tags = {
      "Name" = "eng74-jared-terraform-app"
    }
}

output "test" {
  value = templatefile("./template.tpl", { db-ip = aws_instance.mongodb_instance.private_ip })
}