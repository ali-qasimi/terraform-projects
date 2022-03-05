data "aws_availability_zones" "available" {
    state = "available"
} 

locals {
    availability_zones     = data.aws_availability_zones.available.names
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
