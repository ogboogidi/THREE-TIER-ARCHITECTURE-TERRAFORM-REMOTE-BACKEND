output "vpc_id" {
  value = aws_vpc.apci-s3-reader-app-main-vpc.id
}


output "frontend_subnet_ids" {
  value = [
    aws_subnet.apci_frontend_subnet_01_Az2a.id,
    aws_subnet.apci_frontend_subnet_02_Az2b.id
  ]
  
  }