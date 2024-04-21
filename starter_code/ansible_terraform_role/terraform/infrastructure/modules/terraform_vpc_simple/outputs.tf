output "vpc" {
  value = aws_vpc.main
}

output "sn" {
  value = aws_subnet.main
}

output "gw" {
  value = aws_internet_gateway.main
}

output "rt" {
  value = aws_route_table.main
}
