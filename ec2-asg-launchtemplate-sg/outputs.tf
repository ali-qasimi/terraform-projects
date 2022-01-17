output "security_group_id" {
    value = aws_security_group.web_instance_sg.id
}

output "launch_template_id" {
    value = aws_launch_template.web_launch_template.id
}

output "asg_id" {
    value = aws_autoscaling_group.asg.id
}