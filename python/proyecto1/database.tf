# DB Subnet Group: RDS requiere saber en qué subnets puede operar.
# Debe abarcar al menos dos Zonas de Disponibilidad para alta disponibilidad.
resource "aws_db_subnet_group" "default" {
  name       = "django-db-subnet-group"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  tags       = { Name = "DB-SubnetGroup-Django" }
}

# Security Group para la base de datos: solo permite tráfico en el puerto de PostgreSQL.
resource "aws_security_group" "rds_sg" {
  name   = "rds-sg-django"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Abierto para permitir migraciones desde nuestra IP local.
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "SG-RDS-Django" }
}

# Recurso de la instancia de base de datos RDS.
resource "aws_db_instance" "main" {
  identifier           = "django-db-andres"
  allocated_storage    = 20               # 20 GB de almacenamiento
  engine               = "postgres"
  engine_version       = "16.2"
  instance_class       = "db.t3.micro"    # Elegible para el Free Tier
  db_name              = "django_db"
  username             = "admin"
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true             # No crear un snapshot al destruir (para el taller).
  publicly_accessible  = true             # Necesario para conectarnos y correr migraciones.
}
