data "aws_vpc" "vpc-72a7bf5b" {
   id = "vpc-72a7bf5b"
   /* filter {
        name    = "tag:environment"
        values  = ["home-lab"]
    }  */
}

data "aws_subnet" "subnet-31ee8c9e" {
    vpc_id = data.aws_vpc.vpc-72a7bf5b.id
    id = "subnet-31ee8c9e"
   /* filter {
        name    = "tag:environment"
        values  = ["home-lab"]
    } */
}

resource "aws_security_group" "web_instance_sg" {
    name        = "web-server-security-group"
    description = "Allowing https requests only"
    vpc_id      = data.aws_vpc.vpc-72a7bf5b.id

    tags = {
        Name = "web-server-security-group"
    }
}

resource "aws_launch_template" "web_launch_template" {
    name = "ec2-launch-template"
    image_id = "ami-6ff07e0fbb006c28b"
    instance_type = "t3.medium"
    vpc_security_group_ids = [aws_security_group.web_instance_sg.id]
}

resource "aws_autoscaling_group" "asg" {
    vpc_zone_identifier = [data.aws_subnet.subnet-31ee8c9e.id]
    desired_capacity = 2
    max_size = 3
    min_size = 1

    launch_template {
        id = aws_launch_template.web_launch_template.id
        version = "$Latest"
    }
}