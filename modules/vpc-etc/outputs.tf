# The outputs from the module

# SUBNET IDs
output "private_subnet_id" {
    value = aws_subnet.private_subnet.id
}

output "public_subnet_id" {
    value = aws_subnet.public_subnet.id
}

# SECURITY GROUP IDs
output "private_security_group_id" {
    value = aws_security_group.dbSG.id
}

output "public_security_group_id" {
    value = aws_security_group.appSG.id
}
