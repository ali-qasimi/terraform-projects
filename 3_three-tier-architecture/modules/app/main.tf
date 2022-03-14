
//terraform cloudinit_config resource, used to import cloud-init file.
data "cloudinit_config" "config" {
    gzip = true
    base64_encode = true
    part {
        content_type = "text/cloud-config"
        content = templatefile("${path.module}/app_config.yaml", var.db_config)  //passes the db config in 2nd argument
    }
}

//Since we're using localstack, global SSM Parameter for latest AMI doesn't exist. So creating a dummy parameter
resource "aws_ssm_parameter" "latest_ami" {
    name        = "amzn2_ami"
    description = "latest Amazon Linux AMI"
    type        = "String"
    value       = "ami-1234567890"
}

resource "aws_launch_template" "app_server" {
    name_prefix = var.project
    image_id = aws_ssm_parameter.latest_ami.value
    instance_type = "t2.medium"
    user_data = data.cloudinit_config.config.rendered
    key_name = var.ssh_keypair
    vpc_security_group_ids = [var.sg.app_server_sg]
}

resource "aws_autoscaling_group" "app_server_asg" {
    name = "${var.project}-appserver-asg"
    min_size = 1
    max_size = 3
    vpc_zone_identifier = var.vpc.private_subnets
    target_group_arns = [aws_lb_target_group.app_alb_tg.arn] //create the ALB below
    launch_template {
        id = aws_launch_template.app_server.id
        version = aws_launch_template.app_server.latest_version
    }
}

resource "aws_lb" "app_alb" {
    name = "${var.project}-app-alb"
    load_balancer_type = "application"
    subnets = var.vpc.private_subnets
    security_groups = [var.sg.app_alb_sg]
    enable_deletion_protection = true
}

resource "aws_lb_target_group" "app_alb_tg" {
    name = "${var.project}-app-alb-tg"
    target_type = "instance"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc.vpc_id
}

resource "aws_lb_listener" "app_alb_listener" {
    load_balancer_arn = aws_lb.app_alb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.app_alb_tg.arn
    }
}


