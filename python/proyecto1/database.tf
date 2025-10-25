resource "aws_db_subnet_group" "default" {
  name       = "django-db-subnet-group"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  tags       = { Name = "DB-SubnetGroup-Django" }
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg-django"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "SG-RDS-Django" }
}

resource "aws_db_instance" "main" {
  identifier           = "django-db-andres"
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "16.10"
  instance_class       = "db.t3.micro"
  db_name              = "django_db"
  username             = "postgres_admin"
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = true
}
