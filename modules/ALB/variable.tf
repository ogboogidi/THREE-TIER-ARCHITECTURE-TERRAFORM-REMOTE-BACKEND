variable "tags" {
  type = map(string)
}

variable "frontend_subnet_ids" {
  type = list(string)
}

variable "apci_ALB_sg" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "domain" {
  type = string
}