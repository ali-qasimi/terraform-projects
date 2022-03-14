 output "db_config" {
    value = {
        user     = aws_db_instance.mysql_database.username
        password = aws_db_instance.mysql_database.password
        database = aws_db_instance.mysql_database.name
        hostname = aws_db_instance.mysql_database.address
        port     = aws_db_instance.mysql_database.port
    }
} 
