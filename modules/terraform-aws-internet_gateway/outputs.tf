
output "vpc_id" {
  value = aws_internet_gateway.this.vpc_id
}

output "tags" {
  value = aws_internet_gateway.this.tags
}

output "id" {
  value = aws_internet_gateway.this.id
}

output "arn" {
  value = aws_internet_gateway.this.arn
}
