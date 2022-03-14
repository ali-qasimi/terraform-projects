output "vpc" {
    value = {
        vpc_id = aws_vpc.application_vpc.id
        db_subnets = [for subnet in aws_subnet.all_database_subnets: subnet.id]
        private_subnets = [for subnet in aws_subnet.all_private_subnets: subnet.id]
        public_subnets = [for subnet in aws_subnet.all_public_subnets: subnet.id]
    }
}

output "sg" {
    value = {
        web_alb_sg      = aws_security_group.webserver_alb_sg.id
        web_server_sg   = aws_security_group.webserver_sg.id
        app_alb_sg      = aws_security_group.appserver_alb_sg.id
        app_server_sg   = aws_security_group.appserver_sg.id
        db_sg           = aws_security_group.db_sg.id
    }
}








