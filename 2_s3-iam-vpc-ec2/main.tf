
resource "aws_s3_bucket" "log_bucket" {
    bucket  = "ec2-logs"
    acl     = "private"

    tags = {
        Name = "ec2-logs"
        Environment = "homelab"
    }
}

resource "aws_iam_group" "admins" {
    name = "admins"
    path = "/users/"
}

resource "aws_iam_user" "ali" {
    name = "ali"
    
    tags = {
        user-type = "admin"
    }
}

resource "aws_iam_group_policy" "admin-access" {
    name = "admin-access"
    group = aws_iam_group.admins.name

    policy = jsonencode(
        {
            "Version": "2012-10-17"
            "Statement": [
                {
                    "Action": [
                        "s3:*",
                        "ec2:*"
                    ],
                    "Effect": "Allow",
                    "Resource": "*"
                }
            ]
        }
    )


}

resource "aws_iam_group_membership" "add_admins" {
    name = "admin-group-membership"

    users = [
        aws_iam_user.ali.name,
        ]

    group = aws_iam_group.admins.name
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name        = "main"
        Environment = "homelab"
    }
}

resource "aws_subnet" "private-subnet" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = "10.0.1.0/24"
    availability_zone   = var.region
}

resource "aws_network_interface" "EC2_interface" {
    subnet_id   = aws_subnet.private-subnet.id
    private_ips = ["10.0.1.3/24"]
}

//Since we're using localstack, global SSM Parameter for latest AMI doesn't exist. So creating a dummy parameter
resource "aws_ssm_parameter" "latest_ami" {
    name        = "amzn2_ami"
    description = "latest Amazon Linux AMI"
    type        = "String"
    value       = "ami-1234567890"
} 

/*data "aws_ami" "Linux-latest" {
    most_recent = true

    filter {
        name    = "name"
        values  = ["/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"]
    }

    owners = ["self"]
}*/

resource "aws_instance" "linux-instance" {
    ami             = aws_ssm_parameter.latest_ami.value
    instance_type   = var.instance-type

    network_interface {
        network_interface_id    = aws_network_interface.EC2_interface.id
        device_index            = 0
    }

    credit_specification {
      cpu_credits = "unlimited"
    }

    tags = {
        Name = "linux-instance"
        Environment = "homelab"
    }
}
