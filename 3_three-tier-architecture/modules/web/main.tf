data "cloudinit_config" "config" {
    gzip = true
    base64_encode = true
    part {
        content_type = "text/cloud-config"
        content = templatefile("${path.module}/web_config.yaml", {})  //no arguments required
    }
}

//Since we're using localstack, global SSM Parameter for latest AMI doesn't exist. So creating a dummy parameter
resource "aws_ssm_parameter" "latest_ami" {
    name        = "amzn2_ami"
    description = "latest Amazon Linux AMI"
    type        = "String"
    value       = "ami-1234567890"
}

resource "aws_launch_template" "web_server" {
    name_prefix = var.project
    image_id = aws_ssm_parameter.latest_ami.value
    instance_type = "t2.medium"
    user_data = data.cloudinit_config.config.rendered
    key_name = var.ssh_keypair
    vpc_security_group_ids = [var.sg.web_server_sg]
}

resource "aws_autoscaling_group" "web_server_asg" {
    name = "${var.project}-webserver-asg"
    min_size = 1
    max_size = 3
    vpc_zone_identifier = var.vpc.public_subnets
    target_group_arns = [aws_lb_target_group.web_alb_tg.arn] //create the ALB below
    launch_template {
        id = aws_launch_template.web_server.id
        version = aws_launch_template.web_server.latest_version
    }
}

resource "aws_lb" "web_alb" {
    name = "${var.project}-web-alb"
    load_balancer_type = "application"
    subnets = var.vpc.public_subnets
    security_groups = [var.sg.web_alb_sg]
    enable_deletion_protection = true
}

resource "aws_lb_target_group" "web_alb_tg" {
    name = "${var.project}-web-alb-tg"
    target_type = "instance"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc.vpc_id
}

resource "aws_lb_listener" "web_alb_listener" {
    load_balancer_arn = aws_lb.web_alb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.web_alb_tg.arn
    }
}