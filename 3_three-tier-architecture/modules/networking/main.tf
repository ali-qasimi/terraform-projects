data "aws_availability_zones" "available" {
    state = "available"
} 

locals {
    availability_zones = data.aws_availability_zones.available.names
}

variable "all_security_groups" {
    description = "list of security groups to create"
    type = list(string)
    default = ["webserver_alb_sg", "webserver_sg", "appserver_alb_sg", "appserver_sg", "db_sg"]
}

resource "aws_vpc" "application_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name        = "application_vpc"
        Environment = "development"
    }
} 


resource "aws_subnet" "all_private_subnets" {
    count               = length(local.availability_zones)
    vpc_id              = aws_vpc.application_vpc.id
    cidr_block          = cidrsubnet(aws_vpc.application_vpc.cidr_block, 16, count.index+1)
    availability_zone   = local.availability_zones[count.index]
}

resource "aws_subnet" "all_public_subnets" {
    count               = length(local.availability_zones)
    vpc_id              = aws_vpc.application_vpc.id
    cidr_block          = cidrsubnet(aws_vpc.application_vpc.cidr_block, 16, count.index+11)
    availability_zone   = local.availability_zones[count.index]
}

resource "aws_subnet" "all_database_subnets" {
    count               = length(local.availability_zones)
    vpc_id              = aws_vpc.application_vpc.id
    cidr_block          = cidrsubnet(aws_vpc.application_vpc.cidr_block, 16, count.index+21)
    availability_zone   = local.availability_zones[count.index]
}

resource "aws_security_group" "http_80_inbound" {
    name        = "http_80_inbound"
    description = "allows inbound http traffic"
    vpc_id      = aws_vpc.application_vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "sg_for_all" {
    
    for_each = toset(var.all_security_groups)
    
    name = each.value
    description = "security group for ${each.value}"
    vpc_id = aws_vpc.application_vpc.id
    ingress {
        from_port       = 0
        to_port         = 0
        protocol        = -1
        security_groups = [aws_security_group.http_80_inbound.id]
    }
}



/* resource "aws_security_group" "db_sg" {
    name        = "db_sg"
    description = "allows inbound traffic into the mySQL DB"
    vpc_id      = aws_vpc.application_vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = tcp
        cidr_blocks = "0.0.0.0/0"
    }
} */