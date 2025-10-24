provider "aws" {
  region = var.aws_region
}

# --- 1. RED: Define nuestro espacio de red aislado en AWS ---
# VPC: Tu nube privada virtual. Es el contenedor para todos tus recursos de red.
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "VPC-Django-Taller" }
}

# Subnets: Subdivisiones de la VPC en diferentes zonas de disponibilidad para alta redundancia.
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  tags = { Name = "Subnet-Public-A" }
}
resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
  tags = { Name = "Subnet-Public-B" }
}

# IGW y Route Table: Permiten que los recursos en las subnets públicas se comuniquen con internet.
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "IGW-Django-Taller" }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "RT-Public-Django" }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# --- 2. SEGURIDAD: Controla el acceso a nuestros recursos ---
# Security Group: Actúa como un firewall virtual para la instancia EC2.
resource "aws_security_group" "ec2_sg" {
  name   = "ec2-sg-django"
  vpc_id = aws_vpc.main.id
  # Ingress (entrante): permite tráfico HTTP desde cualquier lugar.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress (saliente): permite que la instancia se conecte a cualquier lugar (para actualizaciones, ECR, etc.).
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "SG-EC2-Django" }
}

# IAM Role: Otorga permisos a la instancia EC2 para interactuar con otros servicios de AWS de forma segura.
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role-django"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

# Adjuntamos políticas: permisos para leer de ECR y para escribir en CloudWatch Logs.
resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# Instance Profile: Es el contenedor que une el rol IAM a la instancia EC2.
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile-django"
  role = aws_iam_role.ec2_role.name
}

# --- 3. SERVIDOR: La instancia de cómputo donde corre nuestra aplicación ---
resource "aws_instance" "django_server" {
  ami                         = "ami-0c101f26f147fa7fd" # Amazon Linux 2023 (us-east-2)
  instance_type               = "t3.micro"              # Elegible para el Free Tier
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true
  tags                        = { Name = "Servidor-Django-Andres" }

  # user_data: Script que se ejecuta una sola vez al iniciar la instancia por primera vez.
  # Automatiza la instalación de Docker, el login a ECR y el lanzamiento del contenedor.
  user_data = <<-EOF
  #!/bin/bash
  set -e
  yum update -y
  yum install -y docker
  service docker start
  usermod -a -G docker ec2-user

  aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.ecr_repo_url}

  docker run -d -p 80:80 --restart unless-stopped \
    --log-driver=awslogs \
    --log-opt awslogs-region=${var.aws_region} \
    --log-opt awslogs-group="taller-django-logs" \
    --log-opt awslogs-create-group=true \
    -e SECRET_KEY='${var.secret_key}' \
    -e DB_NAME='${aws_db_instance.main.db_name}' \
    -e DB_USER='${aws_db_instance.main.username}' \
    -e DB_PASSWORD='${var.db_password}' \
    -e DB_HOST='${aws_db_instance.main.address}' \
    -e DB_PORT='${aws_db_instance.main.port}' \
    ${var.ecr_repo_url}:latest
  EOF
}
