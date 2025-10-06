

variable "vpc_cidr_block" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "frontend_subnet_cidr_block" {
  type = list(string)
}

variable "availability_zone" {
  type = list(string)
}

variable "apci_backend_cidr_block" {
  type = list(string)
}

variable "database_cidr_block" {
  type = list(string)
}