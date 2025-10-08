#configure vpc for your infrastructure

resource "aws_vpc" "apci-s3-reader-app-main-vpc" {
    cidr_block = var.vpc_cidr_block


    tags = merge(var.tags,
        {
            Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-${var.tags.owner}-main_vpc" 
        }
    )

}

##########################################################################################################################################
#create the internet gateway  

resource "aws_internet_gateway" "apci-igw" {
  vpc_id = aws_vpc.apci-s3-reader-app-main-vpc.id

      tags = merge(var.tags,
        {
            Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-${var.tags.owner}-igw" 
        }
    )

}

##################################################################################################################################
#create the frontend subnets for AZ2a and AZ2B

resource "aws_subnet" "apci_frontend_subnet_01_Az2a" {
  vpc_id                   =  aws_vpc.apci-s3-reader-app-main-vpc.id
  cidr_block               =  var.frontend_subnet_cidr_block[0]
  availability_zone        =  var.availability_zone[0]
  map_public_ip_on_launch = true


      tags = merge(var.tags,
        {
            Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-${var.tags.owner}-frontend_subnet_01_Az2a" 
        }
    )
}

resource "aws_subnet" "apci_frontend_subnet_02_Az2b" {
  vpc_id                   = aws_vpc.apci-s3-reader-app-main-vpc.id
  cidr_block               =  var.frontend_subnet_cidr_block[1]
  availability_zone        =  var.availability_zone[1]
  map_public_ip_on_launch = true


      tags = merge(var.tags,
        {
            Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-${var.tags.owner}-frontend_subnet_02_Az2b" 
        }
    )
}

######################################################################################################################################
#create backend subnets for AZ2a and AZ2b

resource "aws_subnet" "apci_backend_subnet_03_AZ2a" {
    vpc_id = aws_vpc.apci-s3-reader-app-main-vpc.id
    cidr_block = var.apci_backend_cidr_block[0]
    availability_zone   = var.availability_zone[0]
    map_public_ip_on_launch = false
    

      tags = merge(var.tags,
        {
            Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-${var.tags.owner}-backend_subnet_03_AZ2a" 
        }
    )
}



resource "aws_subnet" "apci_backend_subnet_04_AZ2b" {
    vpc_id = aws_vpc.apci-s3-reader-app-main-vpc.id
    cidr_block = var.apci_backend_cidr_block[1]
    availability_zone   = var.availability_zone[1]
    map_public_ip_on_launch = false
    

      tags = merge(var.tags,
        {
            Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-${var.tags.owner}-backend_subnet_04_AZ2b" 
        }
    )
}



###################################################################################################################################
 #create database subnets in AZ2a and AZ2b
 resource "aws_subnet" "apci_database_subnet_05_AZ2a" {
   vpc_id = aws_vpc.apci-s3-reader-app-main-vpc.id
   cidr_block = var.database_cidr_block[0]
   availability_zone = var.availability_zone[0]
   map_public_ip_on_launch = false


   tags = merge(var.tags,
        {
            Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-${var.tags.owner}-database_subnet_05_AZ2a" 
        }
    )
}


 resource "aws_subnet" "apci_database_subnet_06_AZ2b" {
   vpc_id = aws_vpc.apci-s3-reader-app-main-vpc.id
   cidr_block = var.database_cidr_block[1]
   availability_zone = var.availability_zone[1]
   map_public_ip_on_launch = false


   tags = merge(var.tags,
        {
            Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-${var.tags.owner}-database_subnet_06_AZ2b" 
        }
    )
}

###################################################################################################################################
#create a public route table and associate with frontend subnets

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.apci-s3-reader-app-main-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.apci-igw.id
    }


    tags = merge(var.tags,
        {
            Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-${var.tags.owner}-public-rt" 
        }
    )
}

resource "aws_route_table_association" "frontend_subnet_01_Az2a" {
  route_table_id = aws_route_table.public_rt
  subnet_id = aws_subnet.apci_frontend_subnet_01_Az2a.id
}


resource "aws_route_table_association" "frontend_subnet_02_Az2b" {
  route_table_id = aws_route_table.public_rt
  subnet_id = aws_subnet.apci_frontend_subnet_02_Az2b.id
}


###################################################################################################################################
#create an two EIPs for AZ2a and AZ2b NAT-GWs

resource "aws_eip" "EIP_NAT_gw_AZ2a" {
  domain = "vpc"

}

resource "aws_eip" "EIP_NAT_gw_AZ2b" {
  domain = "vpc"

}


###################################################################################################################################
#create NAT-GWs for AZ2a and AZ2b 

resource "aws_nat_gateway" "NAT_gw_AZ2a" {
  subnet_id = aws_subnet.apci_frontend_subnet_01_Az2a.id
  allocation_id = aws_eip.EIP_NAT_gw_AZ2a.id
  

  depends_on = [ aws_eip.EIP_NAT_gw_AZ2a, aws_subnet.apci_frontend_subnet_01_Az2a ]
}


resource "aws_nat_gateway" "NAT_gw_AZ2b" {
  subnet_id = aws_subnet.apci_frontend_subnet_02_Az2b.id
  allocation_id = aws_eip.EIP_NAT_gw_AZ2b.id
  

  depends_on = [ aws_eip.EIP_NAT_gw_AZ2a, aws_subnet.apci_frontend_subnet_02_Az2b ]
}



###################################################################################################################################
#create private route table for backend and database subnets in AZ2a

resource "aws_route_table" "private_rt_AZ2a" {
  vpc_id = aws_vpc.apci-s3-reader-app-main-vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT_gw_AZ2a.id

  }

    tags = merge(var.tags,
        {
            Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-${var.tags.owner}-private_rt_AZ2a" 
        }
    )
}


resource "aws_route_table_association" "backend_subnet_03_AZ2a" {
  route_table_id = aws_route_table.private_rt_AZ2a.id
  subnet_id = aws_subnet.apci_backend_subnet_03_AZ2a.id

}

resource "aws_route_table_association" "database_subnet_05_AZ2a" {
  route_table_id = aws_route_table.private_rt_AZ2a.id
  subnet_id = aws_subnet.apci_database_subnet_05_AZ2a.id

}


###################################################################################################################################
#create private route table for backend and database subnets in AZ2b

resource "aws_route_table" "private_rt_AZ2b" {
  vpc_id = aws_vpc.apci-s3-reader-app-main-vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT_gw_AZ2b.id

  }

    tags = merge(var.tags,
        {
            Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-${var.tags.owner}-private_rt_AZ2b" 
        }
    )
}


resource "aws_route_table_association" "backend_subnet_04_AZ2b" {
  route_table_id = aws_route_table.private_rt_AZ2b.id
  subnet_id = aws_subnet.apci_backend_subnet_04_AZ2b.id

}

resource "aws_route_table_association" "database_subnet_06_AZ2b" {
  route_table_id = aws_route_table.private_rt_AZ2b.id
  subnet_id = aws_subnet.apci_database_subnet_06_AZ2b.id

}
