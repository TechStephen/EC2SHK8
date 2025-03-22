output "subnet_id" {
  value = aws_subnet.ec2_public_subnet_1.id
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}