
//terraform resource used to generate random password. Not an AWS resource
resource "random_password" "password" {
    length           = 16
    special          = true
    override_special = "_%*"
}

resource "aws_db_subnet_group" "mysql_subnet_group" {
    name = "mysql_subnet_group"
    subnet_ids = var.vpc.db_subnets
}

resource "aws_db_instance" "mysql_database" {
    allocated_storage = 15
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.small"
    name = "mysql_database"
    identifier = "${var.project}-mysql-database"
    username = "admin"
    password = random_password.password.result
    db_subnet_group_name = aws_db_subnet_group.mysql_subnet_group.name
    vpc_security_group_ids = [var.sg.db_sg]
    skip_final_snapshot = false
}