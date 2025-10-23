#import "linear/main.typ" as linear

#show: linear.theme.with(aspect-ratio: "16-9")

#linear.title-slide(
  title: [Deploy en la nube... ☁️],
  subtitle: [AWS (EC2, Cloudwatch) + Django + Docker + nginx],
)

#linear.outline-slide()

#linear.slide(
  title: [Introducción],
  subtitle: [El resultado final],
)[
  Vamos a construir esto:

  - Un proyecto Django corriendo en producción
  - Dockerizado y desplegado en EC2
  - Conectado a PostgreSQL en RDS
  - Con un dominio personalizado y HTTPS
  - Todo gestionado con Terraform

  #linear.callout(title: [Y lo mejor])[
    Todo gratis usando el tier gratuito de AWS.
  ]
]

#linear.slide(title: [Por qué importa hacerlo bien])[
  Podrías hacer click en la consola de AWS y crear recursos manualmente. Pero eso tiene problemas:

  #linear.two-columns(
    split: 50%,
    [
      *Forma manual (problemas):*
      - No es repetible
      - No hay historial de cambios
      - Difícil de compartir con el equipo
      - Imposible de revisar en code review
    ],
    [
      *Con código (IaC):* #h(0.3em) #linear.badge[Recomendado]
      - Repetible
      - Versionable con git
      - Revisable en code reviews
      - El código es la documentación
    ],
  )

  Hoy vamos a hacerlo con código desde el principio.
]

#linear.section-slide[Paso 1: Proyecto Django]

#linear.slide(
  title: [Proyecto Django],
  subtitle: [Configuración inicial],
)[
  Primero, el proyecto y el entorno virtual:
  #block(width: 80%)[
    ```bash
    python3.12 -m pip install django
    python3.12 -m django startproject django_ec2_complete
    cd django_ec2_complete

    python3.12 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    ```
  ]

  Luego, las dependencias de producción:
  #block(width: 80%)[
    ```bash
    pip install django gunicorn psycopg2-binary
    pip freeze > requirements.txt
    ```
  ]

  - `gunicorn`: para correr Django en producción (no uses `runserver`)
  - `psycopg2-binary`: para conectar a PostgreSQL
]

#linear.slide(
  title: [Proyecto Django],
  subtitle: [Ejecutar localmente],
)[
  Para verificar que todo funciona:

  #block(width: 80%)[
    ```bash
    python manage.py migrate
    python manage.py runserver
    ```
  ]

  Visita `http://127.0.0.1:8000/` y deberías ver Django funcionando.

  Esto es solo el inicio. Ahora viene la parte interesante.
]

#linear.section-slide[Paso 2: Dockerización]

#linear.slide(
  title: [Por qué Docker],
)[
  Docker resuelve el problema clásico: "funciona en mi máquina".

  Con Docker:
  - Empaquetas tu aplicación con todas sus dependencias.
  - La imagen corre igual en tu laptop, en AWS, en Google Cloud.
  - Simplifica el deployment considerablemente.
]

#linear.slide(
  title: [Crear el Dockerfile],
)[
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
  #linear.callout(title: [Nota de optimización])[
    Usamos `slim-bullseye` para una imagen más pequeña y segura.
  ]
]

#linear.slide(
  title: [Construir y ejecutar Docker],
)[
  Construye la imagen:
  #block(width: 80%)[
    ```bash
    docker build -t django-ec2-complete:latest .
    ```
  ]

  Ejecuta el contenedor:
  #block(width: 80%)[
    ```bash
    docker run -p 8000:8080 django-ec2-complete:latest
    ```
  ]

  Visita `http://localhost:8000/` y Django está corriendo dentro de Docker.
]

#linear.slide(title: [Intermisión: Historia de Docker])[
  #linear.two-columns(
    split: 50%,
    [
      *Antes de Docker (circa 2010)*

      El deployment era un desastre:
      - Instalabas Python manualmente en cada servidor.
      - Configurabas nginx, systemd, etc.
      - Cada servidor era una bola de nieve única y frágil.
    ],
    [
      *El momento Docker (2013)*

      De repente:
      - Tu aplicación es una imagen.
      - La imagen contiene todo lo necesario.
      - Despliegas la misma imagen en todos lados.
    ],
  )
]

#linear.section-slide[Paso 3: Amazon ECR]

#linear.slide(
  title: [Amazon ECR],
  subtitle: [Subir nuestra imagen a la nube],
)[
  ECR (Elastic Container Registry) es el lugar donde AWS hospeda tus imágenes Docker. Piénsalo como GitHub pero para imágenes Docker.

  1. *Crear el registry:*
     #block(width: 90%)[
      ```bash
      aws ecr create-repository --repository-name django-ec2-complete
      # Esto te da un URI, como: 620457613573.dkr.ecr.us-east-1.amazonaws.com/django-ec2-complete
      ```
     ]

  2. *Login, tag y push:*
     #block(width: 90%)[
      ```bash
      # Login a ECR (reemplaza <TU_URI>)
      docker login -u AWS -p $(aws ecr get-login-password --region us-east-1) <TU_URI>.dkr.ecr.us-east-1.amazonaws.com

      # Tag la imagen
      docker tag django-ec2-complete:latest <TU_URI>/django-ec2-complete:latest

      # Push
      docker push <TU_URI>/django-ec2-complete:latest
      ```
     ]
]

#linear.section-slide[Paso 4: Infraestructura con Terraform]

#linear.slide(
  title: [Infrastructure as Code],
  subtitle: [Por qué Terraform],
)[
  Podrías ir a la consola de AWS y hacer click para crear recursos. Pero Terraform es mejor porque defines tu infraestructura como código.

  - *Repetible:* ejecuta el mismo código y obtienes la misma infraestructura.
  - *Versionable:* usa git para trackear cambios.
  - *Revisable:* code reviews para infraestructura.
  - *Documentado:* el código es la documentación.
]

#linear.slide(
  title: [Terraform: Networking],
  subtitle: [VPC, Subnets y Gateways],
)[
  #linear.two-columns(
    split: 55%,
    [
      Definimos nuestra red privada en AWS (VPC) y le damos acceso a internet.

      #block(width: 100%)[
        ```hcl
        provider "aws" {
          region = "us-east-1"
        }

        resource "aws_vpc" "default" {
          cidr_block = "10.0.0.0/16"
          enable_dns_support = true
          enable_dns_hostnames = true
          tags = { Name = "Django_EC2_VPC" }
        }

        resource "aws_internet_gateway" "default" {
          vpc_id = aws_vpc.default.id
          tags = { Name = "Django_EC2_Internet_Gateway" }
        }
        ```
      ]
    ],
    [
      *Componentes de red:*
      - *VPC:* tu red privada aislada.
      - *Internet Gateway:* para acceso desde internet.
      - *Route Table:* controla cómo sale el tráfico.
      - *Subnets:* divisiones dentro de tu VPC. Necesitamos dos para RDS.
      - *Security Groups:* firewall para controlar tráfico.
    ]
  )
]

#linear.slide(
  title: [Terraform: EC2],
  subtitle: [El servidor para Django],
)[
  Creamos el servidor (`aws_instance`) y le damos permisos (`aws_iam_role`) para acceder a ECR.

  El script `user_data` se ejecuta al arrancar el servidor:
  - Instala Docker
  - Hace login en ECR
  - Hace pull de nuestra imagen
  - Ejecuta el contenedor

  #block(width: 100%)[
    ```hcl
    resource "aws_instance" "web" {
      ami                         = "ami-0c101f26f147fa7fd"
      instance_type               = "t3.micro" # Free tier
      subnet_id                   = aws_subnet.subnet1.id
      vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
      associate_public_ip_address = true
      user_data_replace_on_change = true
      iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
      user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install -y docker
        service docker start
        yum install -y aws-cli
        docker login -u AWS -p $(aws ecr get-login-password --region us-east-1) <TU_URI>
        docker pull <TU_URI>/django-ec2-complete:latest
        docker run -d -p 80:8080 \
          --env SECRET_KEY=${var.secret_key} \
          <TU_URI>/django-ec2-complete:latest
      EOF
    }
    ```
  ]
]


#linear.slide(
  title: [Aplicar cambios],
)[
  Una vez definida tu infraestructura en Terraform:
  #block(width: 80%)[
    ```bash
    terraform init
    terraform apply
    ```
  ]
  Terraform te muestra qué va a crear y pide confirmación. Escribe `yes` y espera unos minutos.

  #linear.callout(title: [¡Listo!])[
    Cuando termine, ve a la consola de AWS → EC2 y verás tu servidor corriendo.
  ]
]

#linear.focus-slide[
  Infrastructure as Code
]

#linear.slide(
  title: [¿Por qué declarativo?],
  subtitle: [Imperativo vs. Declarativo],
)[
  Terraform se encarga del *cómo* llegar al estado deseado, tú solo describes el *qué*.
  #linear.two-columns(
    split: 50%,
    [
      *Imperativo (bash script):*
      ```bash
      if server_exists; then
        update_server
      else
        create_server
      fi
      ```
      #align(center)[_Describes los pasos_]
    ],
    [
      *Declarativo (Terraform):*
      ```hcl
      resource "aws_instance" "web" {
        # Esto es lo que quiero
      }
      ```
      #align(center)[_Describes el resultado_]
    ]
  )
]

#linear.section-slide[Paso 5: Base de datos PostgreSQL]

#linear.slide(
  title: [PostgreSQL en RDS],
)[
  Podrías instalar PostgreSQL en tu servidor EC2, pero RDS (Relational Database Service) es mejor:
  - Backups automáticos
  - Actualizaciones gestionadas
  - Alta disponibilidad
  - Escalabilidad

  #linear.callout(title: [Tier gratuito])[
    También está incluido en el tier gratuito de AWS.
  ]
]

#linear.slide(
  title: [Terraform: Instancia RDS],
)[
  Definimos la base de datos PostgreSQL.
  #block(width: 95%)[
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
      instance_class         = "db.t3.micro" # Free tier
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
  ]
]

#linear.slide(
  title: [Conectar Django a RDS],
  subtitle: [Variables de entorno],
)[
  Primero, actualizamos `settings.py` para leer la configuración de la base de datos desde variables de entorno.
  #block(width: 80%)[
    ```python
    import os

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
  ]

  #linear.callout(title: [Importante], type: "danger")[
    Nunca pongas credenciales directamente en el código.
  ]
]

#linear.slide(
  title: [Conectar Django a RDS],
  subtitle: [Actualizar el servidor EC2],
)[
  Pasamos las variables de la base de datos al contenedor Docker en `main.tf`:
  #block(width: 90%)[
    ```hcl
    // Dentro del user_data de aws_instance.web
    docker run -d -p 80:8080 \
      --env SECRET_KEY=${var.secret_key} \
      --env DB_NAME=djangodb \
      --env DB_USER_NM=adam \
      --env DB_USER_PW=${var.db_password} \
      --env DB_IP=${aws_db_instance.default.address} \
      --env DB_PORT=5432 \
      <TU_URI>/django-ec2-complete:latest
    ```
  ]

  Luego, redesplegamos:
  1. Reconstruye y sube la nueva imagen Docker.
  2. Ejecuta `terraform apply`.
]

#linear.section-slide[Paso 6: Dominio y HTTPS]

#linear.slide(
  title: [Dominio personalizado],
  subtitle: [Por qué un Application Load Balancer],
)[
  Podrías apuntar tu dominio directamente a la IP de EC2, pero un Load Balancer (ALB) es la forma profesional de hacerlo:
  - *HTTPS:* Gestiona certificados SSL gratis con AWS Certificate Manager (ACM).
  - *Escalabilidad:* Puede distribuir tráfico entre múltiples servidores.
  - *Alta disponibilidad:* Si un servidor falla, puede redirigir el tráfico a otros.
]

#linear.slide(
  title: [Terraform: Dominio y HTTPS],
)[
  #linear.grid-layout(
    columns: 2,
    gutter: 1.5em,
    linear.card(title: [ACM Certificate])[
      Genera un certificado SSL gratuito para tu dominio.
      ```hcl
      resource "aws_acm_certificate" "cert" {
        domain_name       = "tudominio.com"
        validation_method = "DNS"
      }
      ```
    ],

    linear.card(title: [Application Load Balancer])[
      Crea el balanceador que recibirá el tráfico.
      ```hcl
      resource "aws_lb" "default" {
        load_balancer_type = "application"
        security_groups    = [...]
        subnets            = [...]
      }
      ```
    ],

    linear.card(title: [ALB Listener])[
      Configura el ALB para que escuche en el puerto 443 (HTTPS) usando el certificado.
      ```hcl
      resource "aws_lb_listener" "default" {
        port = 443
        protocol = "HTTPS"
        certificate_arn = aws_acm_certificate.cert.arn
      }
      ```
    ],

    linear.card(title: [Route 53])[
      Crea los records DNS (tipo A) para que tu dominio apunte al Load Balancer.
      ```hcl
      resource "aws_route53_record" "root" {
        name = "tudominio.com"
        type = "A"
        alias { ... }
      }
      ```
    ],
  )
]

#linear.slide(
  title: [Configuración final de Django],
)[
  Finalmente, actualiza `settings.py` para permitir las peticiones desde tu dominio.
  #block(width: 80%)[
    ```python
    ALLOWED_HOSTS = ['tudominio.com', 'www.tudominio.com']

    CSRF_TRUSTED_ORIGINS = [
      'https://tudominio.com',
      'https://www.tudominio.com'
    ]
    ```
  ]

  Reconstruye la imagen, súbela a ECR y ejecuta `terraform apply` por última vez.
]


#linear.section-slide[Cierre]

#linear.slide(
  title: [Resumen],
  subtitle: [Lo que construimos],
)[
  En este workshop desplegaste:

  - Un proyecto Django en producción
  - Dockerizado y versionado en ECR
  - Corriendo en EC2 con infraestructura como código (Terraform)
  - Conectado a una base de datos PostgreSQL gestionada (RDS)
  - Con dominio personalizado y HTTPS

  #linear.callout(title: [¡Felicidades!])[
    Todo usando el tier gratuito de AWS.
  ]
]


#linear.slide(title: [Próximos pasos])[
  Algunas ideas para extender este proyecto:

  #linear.grid-layout(
    columns: 3,
    gutter: 1.5em,
    linear.card(title: [Optimizar Docker])[
      Usa `.dockerignore` para reducir el tamaño de la imagen.
    ],
    linear.card(title: [CI/CD])[
      Automatiza el deployment con GitHub Actions.
    ],
    linear.card(title: [Monitoreo])[
      Implementa logs y métricas con CloudWatch.
    ],
    linear.card(title: [Static Files])[
      Usa S3 + CloudFront para servir archivos estáticos.
    ],
    linear.card(title: [Auto-scaling])[
      Configura múltiples instancias EC2 detrás del load balancer.
    ],
    linear.card(title: [Ambientes])[
      Crea ambientes separados para staging y producción.
    ],
  )
]

#linear.slide(
  title: [Recursos],
)[
  Documentación oficial:
  - Django: `docs.djangoproject.com`
  - Docker: `docs.docker.com`
  - Terraform: `registry.terraform.io/providers/hashicorp/aws`
  - AWS: `docs.aws.amazon.com`

  #v(2em)
  La mejor forma de aprender es construyendo. Toma este proyecto y agrégale features.
]

#linear.focus-slide[
  ¡Gracias!
]

#linear.qa-slide(
  question: [¿Preguntas?],
)
