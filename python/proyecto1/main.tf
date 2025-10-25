provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "VPC-Django-Taller" }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  tags              = { Name = "Subnet-Public-A" }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
  tags              = { Name = "Subnet-Public-B" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "IGW-Django-Taller" }
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

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ec2_sg" {
  name   = "ec2-sg-django"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "SG-EC2-Django" }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-role-django-workshop-v2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile-django-workshop-v2"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "django_server" {
  ami                         = "ami-0c101f26f147fa7fd"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true
  tags                        = { Name = "Servidor-Django-Andres" }

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
