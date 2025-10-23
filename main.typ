#import "@preview/touying:0.6.1": *
#import "@preview/cetz:0.4.2"
#import "@preview/touying-simpres:0.1.0": *

#show raw: set text(size: 11pt)
#show figure.caption: set text(size: 10pt)

#show: touying-simpres.with(
  aspect-ratio: "16-9",
  show-level-one: false,
  config-info(
    title: [Deploy en la nube... ☁️],
    subtitle: [AWS (EC2, Cloudwatch) + Django + Docker + nginx],
  ),
)

#set text(font: "Open Sauce One")

#title-slide[]

= Introducción

== El resultado final

Vamos a construir esto:

- Un proyecto Django corriendo en producción
- Dockerizado y desplegado en EC2
- Conectado a PostgreSQL en RDS
- Con un dominio personalizado y HTTPS
- Todo gestionado con Terraform

*Y lo mejor:* todo gratis usando el tier gratuito de AWS.

== Por qué importa hacerlo bien

Podrías hacer click en la consola de AWS y crear recursos manualmente.

Pero eso tiene problemas:

- No es repetible
- No hay historial de cambios
- Difícil de compartir con el equipo
- Imposible de revisar en code review

Hoy vamos a hacerlo con código desde el principio.

= Paso 1: Proyecto Django

== Crear el proyecto

Primero, lo básico:

```bash
python3.12 -m pip install django
python3.12 -m django startproject django_ec2_complete
cd django_ec2_complete
```

Ahora configuramos un entorno virtual:

```bash
python3.12 -m venv venv
source venv/bin/activate
pip install --upgrade pip
```

== Instalar dependencias

Necesitamos tres cosas:

```bash
pip install django gunicorn psycopg2-binary
pip freeze > requirements.txt
```

- `django`: obviamente, para Django
- `gunicorn`: para correr Django en producción (no uses `runserver`)
- `psycopg2-binary`: para conectar a PostgreSQL

== Ejecutar localmente

```bash
python manage.py migrate
python manage.py runserver
```

Visita `http://127.0.0.1:8000/` y deberías ver Django funcionando.

Esto es solo el inicio. Ahora viene la parte interesante.

= Paso 2: Dockerización

== Por qué Docker

Docker resuelve el problema clásico: "funciona en mi máquina".

Con Docker:
- Empaquetas tu aplicación con todas sus dependencias
- La imagen corre igual en tu laptop, en AWS, en Google Cloud
- Simplifica el deployment considerablemente

== Crear el Dockerfile

```dockerfile
FROM python:3.12.2-slim-bullseye
ENV PYTHONBUFFERED=1
ENV PORT 8080
WORKDIR /app
COPY . /app/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
CMD gunicorn django_ec2_complete.wsgi:application \
    --bind 0.0.0.0:"${PORT}"
EXPOSE ${PORT}
```

Nota: usamos `slim-bullseye` para una imagen más pequeña y segura.

== Construir y ejecutar

```bash
docker build -t django-ec2-complete:latest .
docker run -p 8000:8080 django-ec2-complete:latest
```

Visita `http://localhost:8000/` y Django está corriendo dentro de Docker.

Para detenerlo:

```bash
docker ps
docker kill <image_id>
```

= Intermisión: Historia de Docker

== Antes de Docker (circa 2010)

El deployment era un desastre:

- Instalabas Python manualmente en cada servidor
- Configurabas nginx, configurabas systemd
- "¿Qué versión de Python tiene ese servidor?"
- "¿Instalé todas las dependencias del sistema?"

Cada servidor era una bola de nieve única y frágil.

== El momento Docker (2013)

Docker popularizó los contenedores (la tecnología existía antes, pero Docker la hizo accesible).

De repente:
- Tu aplicación es una imagen
- La imagen contiene todo lo necesario
- Despliegas la misma imagen en todos lados

No más "funciona en mi máquina". Ahora es "funciona en esta imagen, y esa imagen corre en cualquier lado".

= Paso 3: Amazon ECR

== Qué es ECR

ECR es Elastic Container Registry: el lugar donde AWS hospeda tus imágenes Docker.

Piénsalo como GitHub pero para imágenes Docker en vez de código.

Tu servidor EC2 va a hacer pull de esta imagen para correr tu aplicación.

== Configuración previa

Necesitas dos cosas:

1. Una cuenta de AWS (obvia)
2. AWS CLI instalado localmente

```bash
# Instalar AWS CLI v2 (según tu OS)
# Luego autenticarte
aws configure
```

== Crear el registry y subir la imagen

```bash
# Crear el registry
aws ecr create-repository \
  --repository-name django-ec2-complete

# Esto te da un URI, algo como:
# 620457613573.dkr.ecr.us-east-1.amazonaws.com/django-ec2-complete
```

== Login y push

```bash
# Login a ECR
docker login -u AWS -p $(aws ecr get-login-password \
  --region us-east-1) \
  <TU_URI>.dkr.ecr.us-east-1.amazonaws.com

# Tag la imagen
docker tag django-ec2-complete:latest \
  <TU_URI>/django-ec2-complete:latest

# Push
docker push <TU_URI>/django-ec2-complete:latest
```

Tu imagen ahora está en la nube.

= Paso 4: Infraestructura con Terraform

== Por qué Terraform

Podrías ir a la consola de AWS y hacer click para crear:
- Una VPC
- Subnets
- Security groups
- Un servidor EC2

Pero Terraform es mejor porque defines tu infraestructura como código.

== Ventajas de Infrastructure as Code

- *Repetible:* ejecuta el mismo código y obtienes la misma infraestructura
- *Versionable:* usa git para trackear cambios
- *Revisable:* code reviews para infraestructura
- *Documentado:* el código es la documentación

== Instalar Terraform

```bash
# macOS
brew install terraform

# O descarga de terraform.io
```

Luego crea un archivo `main.tf` en tu proyecto.

== Componentes necesarios

Para correr Django en AWS necesitamos:

1. *VPC:* tu red privada en AWS
2. *Internet Gateway:* para acceso desde internet
3. *Subnets:* divisiones dentro de tu VPC
4. *Security Groups:* firewall para controlar tráfico
5. *EC2 Instance:* el servidor que corre Docker
6. *IAM Roles:* permisos para que EC2 acceda a ECR

Vamos uno por uno.

== VPC: Virtual Private Cloud

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Django_EC2_VPC"
  }
}
```

Una VPC es tu red aislada en AWS. Todo lo demás vive dentro de ella.

== Internet Gateway

```hcl
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "Django_EC2_Internet_Gateway"
  }
}
```

Sin esto, tu VPC está completamente aislada del internet. El gateway permite tráfico entrante.

== Route Table

```hcl
resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
  tags = {
    Name = "Django_EC2_Route_Table"
  }
}
```

Las route tables controlan cómo sale el tráfico de tu VPC.

== Subnets

```hcl
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "Django_EC2_Subnet_1" }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "Django_EC2_Subnet_2" }
}
```

*¿Por qué dos subnets?* AWS lo requiere para bases de datos gestionadas (RDS). Más sobre esto después.

== Security Group

```hcl
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.default.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

Este security group permite tráfico HTTP (puerto 80) desde cualquier lugar.

== EC2 Instance (parte 1)

```hcl
variable "secret_key" {
  description = "The Secret Key for Django"
  type        = string
  sensitive   = true
}

resource "aws_instance" "web" {
  ami                    = "ami-0c101f26f147fa7fd"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  user_data_replace_on_change = true
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  # (continúa en siguiente slide)
}
```

== EC2 Instance (parte 2)

El `user_data` script se ejecuta cuando el servidor arranca:

```hcl
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    service docker start
    yum install -y aws-cli
    
    docker login -u AWS -p $(aws ecr get-login-password \
      --region us-east-1) <TU_URI>
    
    docker pull <TU_URI>/django-ec2-complete:latest
    
    docker run -d -p 80:8080 \
      --env SECRET_KEY=${var.secret_key} \
      <TU_URI>/django-ec2-complete:latest
  EOF
```

== IAM Roles para ECR

```hcl
resource "aws_iam_role" "ec2_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = { Service = "ec2.amazonaws.com" },
      Effect = "Allow",
    }],
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "django_ec2_complete_profile"
  role = aws_iam_role.ec2_role.name
}
```

== Aplicar los cambios

```bash
terraform init
terraform apply
```

Terraform te muestra qué va a crear y pide confirmación.

Escribe `yes` y espera unos minutos.

Cuando termine, ve a la consola de AWS → EC2 y verás tu servidor corriendo.

= Intermisión: Infrastructure as Code

== La evolución del deployment

*Era 1 (pre-2010):* SSH al servidor, instala cosas manualmente, reza.

*Era 2 (2010-2015):* Scripts bash para automatizar. Mejor, pero frágiles.

*Era 3 (2015-ahora):* Terraform, CloudFormation, Pulumi. Infraestructura declarativa.

== Por qué declarativo es mejor

Imperativo (bash script):
```bash
if server_exists; then
  update_server
else
  create_server
fi
```

Declarativo (Terraform):
```hcl
resource "aws_instance" "web" {
  # Esto es lo que quiero
}
```

Terraform se encarga de cómo llegar ahí.

= Paso 5: Base de datos PostgreSQL

== Por qué PostgreSQL en RDS

Podrías instalar PostgreSQL en tu servidor EC2.

Pero RDS es mejor:
- Backups automáticos
- Actualizaciones gestionadas
- Alta disponibilidad
- Escalabilidad

Y también está en el tier gratuito.

== Crear database.tf

Nuevo archivo para mantener las cosas organizadas:

```hcl
# database.tf

resource "aws_db_subnet_group" "default" {
  subnet_ids = [aws_subnet.subnet1.id, 
                aws_subnet.subnet2.id]
  tags = { Name = "Django_EC2_Subnet_Group" }
}
```

*Aquí es donde necesitamos dos subnets.* RDS requiere subnets en dos availability zones para alta disponibilidad.

== Security Group para RDS

```hcl
resource "aws_security_group" "rds_sg" {
  vpc_id      = aws_vpc.default.id
  description = "Allow PostgreSQL traffic"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

Puerto 5432 es el puerto estándar de PostgreSQL.

== Instancia RDS

```hcl
variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

resource "aws_db_instance" "default" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "16.1"
  instance_class         = "db.t3.micro"
  identifier             = "my-django-rds"
  db_name                = "djangodb"
  username               = "adam"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = true
}
```

== Configurar variables de entorno

```bash
export TF_VAR_secret_key=tu_secret_key
export TF_VAR_db_password=tu_password
```

Ahora cuando ejecutes `terraform apply`, no te pedirá estos valores cada vez.

== Actualizar Django settings

En `settings.py`:

```python
import os

SECRET_KEY = os.getenv('SECRET_KEY')
DEBUG = False
ALLOWED_HOSTS = ['*']

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('DB_NAME'),
        'USER': os.getenv('DB_USER_NM'),
        'PASSWORD': os.getenv('DB_USER_PW'),
        'HOST': os.getenv('DB_IP'),
        'PORT': os.getenv('DB_PORT'),
    }
}
```

== Configurar variables localmente

En `venv/bin/activate`:

```bash
export SECRET_KEY=pass1234
export DB_NAME=djangodb
export DB_USER_NM=adam
export DB_USER_PW=pass1234
export DB_IP=<endpoint_from_aws>
export DB_PORT=5432
```

Reactiva el entorno: `deactivate && source venv/bin/activate`

== Migrar la base de datos

```bash
python manage.py migrate
python manage.py createsuperuser
```

Ahora Django está conectado a PostgreSQL en AWS.

Puedes probarlo localmente: `python manage.py runserver`

== Actualizar el servidor

Necesitas pasar las variables de entorno al contenedor Docker.

En `main.tf`, actualiza el `user_data`:

```hcl
docker run -d -p 80:8080 \
  --env SECRET_KEY=${var.secret_key} \
  --env DB_NAME=djangodb \
  --env DB_USER_NM=adam \
  --env DB_USER_PW=pass1234 \
  --env DB_IP=${aws_db_instance.default.address} \
  --env DB_PORT=5432 \
  <TU_URI>/django-ec2-complete:latest
```

Nota: `${aws_db_instance.default.address}` es dinámico.

== Redesplegar

```bash
# Rebuild imagen con los cambios en settings.py
docker build -t django-ec2-complete:latest .
docker tag django-ec2-complete:latest <TU_URI>:latest
docker push <TU_URI>:latest

# Aplicar cambios en Terraform
terraform apply --auto-approve
```

Ahora tu servidor EC2 corre Django conectado a PostgreSQL en RDS.

= Paso 6: Dominio personalizado

== Por qué un load balancer

Podrías apuntar tu dominio directamente a la IP de EC2.

Pero un load balancer te da:
- HTTPS (con certificado SSL)
- Escalabilidad (múltiples servidores)
- Alta disponibilidad

Es la forma profesional de hacerlo.

== Crear domain.tf

Nuevo archivo para recursos de dominio:

```hcl
# domain.tf

resource "aws_acm_certificate" "cert" {
  domain_name       = "tudominio.com"
  validation_method = "DNS"
  subject_alternative_names = ["www.tudominio.com"]
  
  lifecycle {
    create_before_destroy = true
  }
}
```

ACM (AWS Certificate Manager) te da certificados SSL gratis.

== Route 53 zone

Si compraste tu dominio en Route 53:

```hcl
data "aws_route53_zone" "selected" {
  name = "tudominio.com"
}
```

Si usas otro registrar (GoDaddy, Namecheap), necesitas configurar nameservers manualmente.

== Records para validación

```hcl
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : 
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}
```

Esto valida que eres dueño del dominio.

== Load Balancer

```hcl
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.default.id
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
}

resource "aws_lb" "default" {
  name               = "django-ec2-alb-https"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet1.id, 
                        aws_subnet.subnet2.id]
}
```

== Target Group

```hcl
resource "aws_lb_target_group" "default" {
  name     = "django-ec2-tg-https"
  port     = 443
  protocol = "HTTP"
  vpc_id   = aws_vpc.default.id
}

resource "aws_lb_target_group_attachment" "default" {
  target_group_arn = aws_lb_target_group.default.arn
  target_id        = aws_instance.web.id
  port             = 80
}
```

El target group conecta el load balancer a tu servidor EC2.

== Listener HTTPS

```hcl
resource "aws_lb_listener" "default" {
  load_balancer_arn = aws_lb.default.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}
```

Esto hace que el load balancer escuche en puerto 443 (HTTPS) y reenvíe al servidor.

== Records A para el dominio

```hcl
resource "aws_route53_record" "root_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "tudominio.com"
  type    = "A"
  
  alias {
    name                   = aws_lb.default.dns_name
    zone_id                = aws_lb.default.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www.tudominio.com"
  type    = "A"
  
  alias {
    name                   = aws_lb.default.dns_name
    zone_id                = aws_lb.default.zone_id
    evaluate_target_health = true
  }
}
```

== Actualizar Django settings

No olvides actualizar `CSRF_TRUSTED_ORIGINS`:

```python
CSRF_TRUSTED_ORIGINS = [
  'https://tudominio.com', 
  'https://www.tudominio.com'
]
```

Rebuild, push, y `terraform apply`.

= Cierre

== Lo que construimos

En este workshop desplegaste:

1. ✓ Un proyecto Django en producción
2. ✓ Dockerizado y versionado en ECR
3. ✓ Corriendo en EC2 con Terraform
4. ✓ Conectado a PostgreSQL en RDS
5. ✓ Con dominio personalizado y HTTPS

Todo usando el tier gratuito de AWS.

== Mejoras posibles

Algunas ideas para extender este proyecto:

- *Optimizar Docker:* usa `.dockerignore` para reducir el tamaño de imagen
- *CI/CD:* automatiza el deployment con GitHub Actions
- *Múltiples ambientes:* staging y producción separados
- *Monitoring:* CloudWatch para logs y métricas
- *Static files:* usa S3 + CloudFront para archivos estáticos
- *Auto-scaling:* múltiples instancias EC2 detrás del load balancer

== Recursos

Documentación oficial:
- Django: docs.djangoproject.com
- Docker: docs.docker.com
- Terraform: terraform.io/docs
- AWS: docs.aws.amazon.com

La mejor forma de aprender es construyendo. Toma este proyecto y agrégale features.

#focus-slide[¡Gracias!]

#slide(footer: "", show-level-one: false)[
  #align(center + horizon)[
    #text(size: 24pt)[¿Preguntas?]
  ]
]