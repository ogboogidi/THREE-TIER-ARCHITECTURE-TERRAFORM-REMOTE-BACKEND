# create security group for ALB

resource "aws_security_group" "apci_ALB_sg" {
  name = "apci_ALB_sg"
  vpc_id = var.vpc_id
  description = "allow HTTP and HTTPS traffic and all outbound"

  tags = merge(var.tags,
        {
            Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-${var.tags.owner}-ALB_sg" 
        }
    )
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP" {
  security_group_id = aws_security_group.apci_ALB_sg.id
  description = "Allow HTTP traffic from the internet"
  cidr_ipv4 = "0.0.0.0/0"
  to_port = 80
  ip_protocol = "tcp"
  from_port = 80
  
  }


resource "aws_vpc_security_group_ingress_rule" "allow_HTTPS" {
  security_group_id = aws_security_group.apci_ALB_sg.id
  description = "Allow HTTPS traffic from the internet"
  cidr_ipv4 = "0.0.0.0/0"
  to_port = 443
  ip_protocol = "tcp"
  from_port = 443

}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.apci_ALB_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1" 
}


################################################################################################################################
#create security group for Bastion host

resource "aws_security_group" "apci_bastion_host_sg" {
  name = "apci_bastion_host_sg"
  vpc_id = var.vpc_id
  description = "allow SSH traffic and all outbound"

  tags = merge(var.tags,
        {
            Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-${var.tags.owner}-bastion_host_sg" 
        }
    )
}

resource "aws_vpc_security_group_ingress_rule" "allow_SSH" {
  security_group_id = aws_security_group.apci_bastion_host_sg.id
  description = "Allow SSH traffic from the anywhere"
  cidr_ipv4 = "0.0.0.0/0"
  to_port = 22
  ip_protocol = "tcp"
  from_port = 22
  
  }


resource "aws_vpc_security_group_egress_rule" "allow_ssh_traffic" {
  security_group_id = aws_security_group.apci_ALB_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1" 
}



################################################################################################################################
#create security group for frontend servers


resource "aws_security_group" "apci_frontend_svr_sg" {
  name = "apci_frontend_svr_sg"
  vpc_id = var.vpc_id
  description = "allow HTTP traffic from ALB and all outbound"

  tags = merge(var.tags,
        {
            Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-${var.tags.owner}-apci_frontend_svr_sg" 
        }
    )
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP_ALB" {
  security_group_id = aws_security_group.apci_frontend_svr_sg.id
  description = "Allow HTTP traffic from the ALB"
  referenced_security_group_id = aws_security_group.apci_ALB_sg.id
  to_port = 80
  ip_protocol = "tcp"
  from_port = 80
  
  }


resource "aws_vpc_security_group_egress_rule" "allow_All_HTTP_ALB_traffic" {
  security_group_id = aws_security_group.apci_ALB_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1" 
}
