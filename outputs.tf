###########################
########### VPC ###########
###########################
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "The ID of the Public Subnet"
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "The ID of the Private Subnet"
}

###########################
########### EC2 ###########
###########################
output "ec2_public_ipv4" {
  value       = aws_instance.web.public_ip
  description = "The public IPv4 address of the EC2 instance"
}

output "ec2_id" {
  value       = aws_instance.web.id
  description = "The ID of the EC2 instance"
}

###########################
########### RDS ###########
###########################
output "rds_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "The endpoint of the RDS instance"
}

output "rds_instance_id" {
  value       = aws_db_instance.postgres.id
  description = "The ID of the RDS instance"
}
