output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnet" {
  value = {
    cidr_blocks = aws_subnet.private_subnets[*].cidr_block
    ids         = aws_subnet.private_subnets[*].id
  }
}

output "public_subnet" {
  value = {
    cidr_blocks = aws_subnet.public_subnets[*].cidr_block
    ids         = aws_subnet.public_subnets[*].id
  }
}
