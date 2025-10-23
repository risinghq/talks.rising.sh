#import "linear/main.typ" as linear

#show: linear.theme.with(aspect-ratio: "16-9")

#linear.title-slide(
  title: [Cómo hacer deploy en la nube... ☁️],
  subtitle: [Stack: AWS (EC2, Cloudwatch) + Django + Docker + Terraform + nginx],
)

#linear.outline-slide(title: [La agenda para hoy incluye:])

#linear.slide(
  title: [Introducción],
  subtitle: [El resultado final],
)[
  Vamos a trabajar con dos proyectos basados en Django. Como asumiré que ya manejan este framework, podremos concentrarnos directamente en los aspectos del deploy (o _despliegue_).

  Un detalle importante es que gran parte de lo que veremos hoy también es aplicable a otros frameworks como React, Next.js o Astro.

  El plan es:

  - Dockerizar ambos proyectos y desplegarlos en Amazon EC2
  - Configurar un dominio personalizado con certificado HTTPS
  - Gestionar toda la infraestructura usando Terraform

  #linear.callout(title: [Importante])[
    El workshop está diseñado para que no tenga costo alguno. A menos que necesites escalar para más de 100 usuarios concurrentes, el tier gratuito de AWS será más que suficiente.
  ]
]

#linear.slide(
  title: [Introducción],
  subtitle: [Preparación del entorno de trabajo],
)[
  Para este workshop vamos a necesitar:

  - Python 3.x (para trabajar de forma local)
  - AWS CLI (para conectarnos con Amazon Web Services)
  - GitHub CLI (gh) (para gestionar nuestros repositorios)

  Además, usaremos nginx, Docker y Terraform, aunque no será necesario instalarlos localmente.

  Empecemos verificando qué tienes ya instalado. Abre tu terminal (PowerShell o CMD en Windows, Terminal en Mac/Linux) y ejecuta estos comandos uno por uno:

  ```bash
  python --version || python3 --version

  # Verifica si tienes AWS CLI
  aws --version

  # Verifica si tienes GitHub CLI
  gh --version
  ```

  #figure(
    image("img/version.png", width: 75%),
  )

  Si ves que aparecen números de versión, ¡genial! Esa herramienta está lista y puedes continuar. Si en cambio te muestra un error o dice que el comando no existe, significa que necesitas instalarla.

  Si ya tienes todo configurado, puedes saltar directamente a la siguiente sección.

  Mmm... así que te faltan algunas herramientas. Tienes dos opciones (personalmente te recomiendo usar la primera opción):

  1. Si te falta alguna herramienta, te recomiendo usar #link("[https://mise.jdx.dev/getting-started.html")[mise]. Es práctico y te permite instalar y gestionar todas las dependencias necesarias *con un solo comando*, además de cambiar fácilmente de versión según el proyecto.

    #linear.callout(title: [Ventajas de usar mise])[
      - Gestiona Python, AWS CLI y GitHub CLI desde un mismo lugar
      - Permite cambiar de versión fácilmente según el proyecto
      - Es más intuitiva que alternativas como pyenv o asdf (además de que solo sirven para Python)
      - No necesita permisos de administrador
    ]

  2. También puedes instalar cada herramienta *manualmente* por separado desde sus páginas oficiales: #link("https://www.python.org/downloads/")[python.org], #link("https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html")[aws.amazon.com/cli], #link("https://cli.github.com/")[cli.github.com]
]

#linear.section-slide[Proyecto \#0: Django]

#linear.slide(
  title: [Django],
  subtitle: [Configuración inicial],
)[
  Vamos a crear un proyecto base de Django desde cero.
  Este primer proyecto servirá para entender la estructura y preparar el entorno correctamente.

  1. Crear la carpeta del proyecto
    #block(width: 80%)[
      ```bash
      mkdir ejemplo && cd ejemplo
      ```
    ]

    Esto crea una carpeta vacía donde guardaremos todo el código.
    Mantener cada proyecto en su propio directorio evita confusiones y mezclas de archivos.

  2. Crear un entorno virtual
    #block(width: 80%)[
      ```bash
      python -m venv venv
      source venv/bin/activate  # En Windows usa: venv\Scripts\activate
      ```
    ]

    El entorno virtual aísla las dependencias del proyecto.
    Esto evita conflictos entre versiones de librerías en distintos proyectos.

  3. Instalar dependencias básicas
    #block(width: 80%)[
      ```bash
      python -m pip install django gunicorn psycopg2-binary
      ```
    ]
    Se instalan tres paquetes esenciales:

    - django: framework principal
    - gunicorn: servidor de producción
    - psycopg2-binary: conector para bases de datos PostgreSQL
      Empezar con estas dependencias desde el inicio permite usar la misma base tanto en desarrollo como en producción.

  4. Crear el proyecto Django
    #block(width: 80%)[
      ```bash
      python -m django startproject proyecto1
      cd proyecto1
      ```
    ]
    Este comando genera la estructura inicial del proyecto con los archivos de configuración y el servidor de desarrollo.
]

#linear.slide(
  title: [Django],
  subtitle: [Ejecutar localmente],
)[
  Antes de levantar el servidor local, aplicamos las migraciones
  #block(width: 80%)[
    ```bash
    python manage.py migrate
    ```
  ]
  Esto crea la base de datos inicial que Django necesita para manejar usuarios, sesiones y otros componentes internos. Por si acaso, esto forma parte de la plantilla generada por Django. No vamos a tocar bases de datos en este workshop.

  Ahora, podemos ejecutar el servidor local
  #block(width: 80%)[
    ```bash
    python manage.py runserver
    ```
  ]
  Este comando inicia el servidor de desarrollo.
  No se usa en producción, pero permite probar la aplicación localmente.

  #image("img/server.png", width: 80%)

  Finalmente, podemos probar en el navegador:
  #link("http://127.0.0.1:8000/")[http://127.0.0.1:8000/]

  Si aparece la página de inicio de Django, el entorno está correctamente configurado.

  #image("img/local.png", width: 100%)
]

#linear.section-slide[Herramienta \#1: Docker]

#linear.slide(
  title: [Docker],
  subtitle: [¿Por qué usarlo?],
)[
  #linear.two-columns(
    split: 50%,
    [
      *Sin Docker:*
      - Configurar manualmente cada servidor
      - Instalar dependencias (Python, Nginx, etc.)
      - Ajustar según el sistema operativo
      - Inconsistencias entre entornos
      - "Funciona en mi máquina, pero no en producción"
    ],
    [
      *Con Docker:*
      - Empaquetas la app junto con sus dependencias
      - Misma imagen funciona en cualquier entorno
      - Despliegues consistentes
      - Aislamiento entre aplicaciones
    ],
  )

  Para este workshop *no necesitas instalar Docker en tu máquina local*, ya que [1] es un programa que consume bastantes recursos y [2] además las imágenes necesarias ya están disponibles en Docker Hub.

  #linear.callout(title: [¡No te abrumes!])[
    No necesitas memorizar cada comando.
    Lo importante es entender *qué parámetros ajustar y cuándo*.
    En la mayoría de los casos, tu *Dockerfile será muy similar* entre proyectos.
  ]
]

#linear.slide(
  title: [Docker],
  subtitle: [Conceptos básicos],
)[
  *Imagen*: Paquete inmutable que contiene tu aplicación, dependencias, configuración y sistema operativo base. Se construye una vez con `docker build`.

  *Contenedor*: Instancia ejecutable de una imagen. Cada vez que haces `docker run` creas un nuevo contenedor. Puedes tener múltiples contenedores de la misma imagen.

  *Dockerfile*: Archivo de texto con instrucciones para construir una imagen paso a paso.

  #v(1em)

  #align(center)[
    #figure(
      image("img/docker.png", width: 60%),
    )
  ]
]

#linear.slide(
  title: [Docker],
  subtitle: [El Dockerfile],
)[
  ```dockerfile
  FROM python:3.14.0-slim-bullseye

  # Puerto en el que el contenedor expone a la aplicación
  ENV PORT=8080

  # Carpeta de trabajo dentro del contenedor
  WORKDIR /app

  # Copia todo el contenido de la carpeta "proyecto1" (directorio actual)
  # al directorio /app dentro del contenedor Docker.
  COPY . /app/
  # Instalar dependencias
  RUN pip install --upgrade pip && pip install -r requirements.txt

  CMD gunicorn proyecto1.wsgi:application --bind 0.0.0.0:"${PORT}"
  EXPOSE ${PORT}
  ```

  Cada línea es una capa. Docker cachea cada capa para acelerar los siguientes builds.
]

#linear.slide(
  title: [Docker],
  subtitle: [Comandos del Dockerfile],
)[
  #linear.data-table(
    headers: ("Comando", "Descripción"),
    column-widths: (20%, 80%),
    rows: (
      [#raw("FROM")],
      [Imagen base del sistema operativo y runtime. Ejemplo: `python:3.14.0-slim-bullseye`],
      [#raw("WORKDIR")],
      [Directorio de trabajo dentro del contenedor. Crea el directorio si no existe],
      [#raw("ENV")],
      [Variables de entorno disponibles durante build y ejecución],
      [#raw("COPY")],
      [Copia archivos desde tu máquina al contenedor. Ejemplo: `COPY . /app/`],
      [#raw("RUN")],
      [Ejecuta comandos durante la construcción. Ejemplo: `pip install -r requirements.txt`],
      [#raw("CMD")],
      [Comando que se ejecuta al iniciar el contenedor. Solo puede haber uno],
      [#raw("EXPOSE")],
      [Documenta el puerto que usa la aplicación. No publica el puerto automáticamente],
    ),
  )
]

#linear.slide(
  title: [Docker],
  subtitle: [Build vs Runtime],
)[
  Docker tiene dos fases distintas:

  #v(1em)

  *Build time* ( `docker build` ):
  - Se ejecutan: FROM,  WORKDIR, COPY, RUN, ENV
  - Resultado: imagen inmutable
  - Se ejecuta una sola vez (o cuando cambias el Dockerfile)
  - Usa caché de capas para acelerar

  #v(1em)

  *Runtime* ( `docker run` ):
  - Se ejecuta: CMD
  - Resultado: contenedor en ejecución
  - Cada `docker run` crea un nuevo contenedor
  - El contenedor se detiene cuando el proceso de CMD termina

  #v(1em)
]

/*
#linear.slide(
  title: [Docker],
  subtitle: [Sistema de archivos en Linux],
)[
  Docker se ejecuta sobre Linux.
  Cada contenedor es como una pequeña instalación de Linux aislada, con su propio sistema de archivos.

  *Estructura básica*: La raíz del sistema es `/`, también llamada "root". En Windows, podrías compararla con `C:\`. Todas las rutas parten desde `/`. En Linux, las rutas pueden ser absolutas o relativas.

  *Rutas absolutas y relativas*:
  - `/app` es una ruta absoluta (empieza desde `/`)
  - `.` es la carpeta actual. Por ejemplo: si estás en `/app`, entonces `.` significa `/app`
  - `..` es la carpeta padre o superior. Ejemplo: si estás en `/app/python` , entonces  `..`  significa `/app`

  *Comandos comunes en Dockerfile*
  - `WORKDIR /app` crea (si no existe) y cambia al directorio `/app`
  - `COPY . /app/` copia tu código local al directorio `/app` dentro del contenedor

  El sistema de archivos de un contenedor es temporal. Es decir, si eliminas el contenedor, se pierden los cambios. Para guardar datos de forma persistente, usa volúmenes.
]
*/

#linear.slide(
  title: [Docker],
  subtitle: [Comandos],
)[
  Ahora que tenemos el Dockerfile, podemos construir la imagen y ejecutar el contenedor.

  Para construir imagen, ejecuta:
  ```bash
  docker build -t proyecto1-ec2:latest .
  ```

  Una vez construida la imagen, puedes ejecutar el contenedor:
  ```bash
  docker run -d -p 8000:8080 proyecto1-ec2:latest
  ```

  Este comando ejecuta el contenedor y enlaza el puerto 8080 del contenedor con el puerto 8000 de la máquina host.
  En otras palabras, puedes acceder a la aplicación desde #link("http://localhost:8000")[http://localhost:8000]

  Para pausar la imagen, solo ejecuta:
  ```bash
  docker ps
  docker kill <image_id>
  ```
]

#linear.section-slide[Herramienta \#2: Amazon CLI]

#linear.slide(
  title: [AWS CLI],
  subtitle: [AWS ECR],
)[
  Ahora que tenemos la imagen Docker en nuestro equipo, necesitamos subirla a la nube para que nuestro servidor pueda descargarla y ejecutarla. En AWS, esto se hace a través del *Elastic Container Registry (ECR)*.

  Si aún no tienes una cuenta en AWS, puedes crear una de forma gratuita aquí:

  - AWS Educate: #link("https://aws.amazon.com/education/awseducate/")[https://aws.amazon.com/education/awseducate/]
  - AWS Free Tier: #link("https://aws.amazon.com/free/")[https://aws.amazon.com/free/]

  Existen dos formas de crear y gestionar un registro en ECR: manualmente desde la consola de AWS o mediante código.

  #linear.two-columns(
    split: 50%,
    [
      *Manual (desventajas):*
      - No repetible
      - Sin historial de cambios
      - Difícil de compartir con el equipo
      - No permite revisiones en code review
    ],
    [
      *Con código #linear.badge[Recomendado]:*
      - Repetible
      - Versionable con git
      - Revisable en code review
      - El código sirve como documentación
    ],
  )

  Hoy lo haremos directamente con código. Primero, asegúrate de tener instalado *AWS CLI* en tu máquina:
  #figure(
    image("img/awscli.png", width: 63%),
  )

  Verifica la instalación ejecutando:

  ```bash
  aws --version
  ```
]

#linear.slide(
  title: [AWS CLI],
  subtitle: [Iniciar sesión],
)[
  Antes de subir nuestra imagen Docker a ECR, necesitamos iniciar sesión en AWS desde la terminal usando *AWS CLI*.

  1. Dirígete a la sección de usuarios en el #link("https://us-east-1.console.aws.amazon.com/iam/home?region=us-east-2#/users")[IAM Dashboard] y crea un usuario o revisa que tu usuario ya tenga las credenciales necesarias.
    Asegúrate de escoger la opción *"Log in as root user"* si estás generando credenciales para la primera vez.

  2. A continuación, encontrarás una guía paso a paso con capturas de pantalla. Este proceso solo se realiza una vez; podrás reutilizar las credenciales mientras trabajes en la misma región.

  #linear.callout(title: [Ten cuidado])[
    Las credenciales son privadas y no deben compartirse con nadie. Asegúrate de eliminarlas al finalizar el workshop si no planeas utilizarlas en otro proyecto.
  ]

  #figure(image("img/aws-iam.png", width: 90%))
  #figure(image("img/iam/1.png", width: 90%))
  #figure(image("img/iam/2.png", width: 90%))
  #figure(image("img/iam/3.png", width: 90%))
  #figure(image("img/iam/4.png", width: 90%))
  #figure(image("img/iam/5.png", width: 90%))
  #figure(image("img/iam/6.png", width: 90%))
  #figure(image("img/iam/7.png", width: 90%))
  #figure(image("img/iam/8.png", width: 90%))

  3. Configura tus credenciales de AWS en la terminal:

    #block(width: 90%)[
      ```bash
      aws configure
      ```
    ]

    Este comando te pedirá tu *AWS Access Key ID* y *AWS Secret Access Key*, obtenidas del paso anterior. Al momento de escoger tu región, escribe: "us-east-2".

  4. Verifica que la configuración fue correcta:

    #block(width: 90%)[
      ```bash
      aws sts get-caller-identity # Esto mostrará tu ID de usuario, cuenta y ARN
      ```
    ]

    #figure(image("img/aws-cred.png", width: 55%))
]

#linear.slide(
  title: [AWS CLI],
  subtitle: [Subir nuestra imagen Docker a ECR],
)[
  Ahora que tenemos nuestra cuenta de AWS configurada, podemos crear un repositorio en ECR:

  #block(width: 90%)[
    ```bash
    aws ecr create-repository --repository-name proyecto1-ec2
    ```
  ]

  Esto retornará un objeto JSON con información sobre el repositorio creado:

  ```json
  {
      "repository": {
          "repositoryArn": "arn:aws:ecr:us-east-2:***:repository/proyecto1-ec2",
          "registryId": "***",
          "repositoryName": "proyecto1-ec2",
          "repositoryUri": "***.dkr.ecr.us-east-2.amazonaws.com/proyecto1-ec2",
          "createdAt": "2025-10-23T15:42:25.263000-05:00",
          "imageTagMutability": "MUTABLE",
          "imageScanningConfiguration": { "scanOnPush": false },
          "encryptionConfiguration": { "encryptionType": "AES256" }
      }
  }
  ```

  Guarda el valor *repositoryUri* ya que vamos a necesitarlo en el siguiente paso.

  2. Para iniciar sesión en el repositorio de ECR. En esta sección reemplaza <TU_URI> por el valor obtenido en el paso anterior:

    #block[
      ```bash
      docker login -u AWS -p $(aws ecr get-login-password --region us-east-2) <TU_URI>.dkr.ecr.us-east-2.amazonaws.com
      ```
    ]

  3. Etiquetar la imagen:

    #block[
      ```bash
      docker tag proyecto1-ec2:latest <TU_URI>/proyecto1-ec2:latest
      ```
    ]

  4. Subir la imagen al repositorio de ECR:

    #block[
      ```bash
      docker push <TU_URI>/proyecto1-ec2:latest
      ```
    ]

    Este proceso puede que tome un par de minutos. Puedes ir por un café o tomar un descanso.

    Para verificar este proceso, puedes dirigirte a la consola de AWS y buscar la imagen en el repositorio de ECR: #link("https://us-east-2.console.aws.amazon.com/ecr/home?region=us-east-2#")[https://us-east-2.console.aws.amazon.com/ecr/home?region=us-east-2#]

    #figure(image("img/aws-ecr.png", width: 70%))
]


#linear.section-slide[Herramienta \#2: Terraform]

#linear.slide(
  title: [Terraform],
  subtitle: [¿Por qué lo estamos usando?],
)[
  Terraform es una herramienta de *Infrastructure as Code* (IaC) que permite definir y gestionar recursos mediante código declarativo.

  Ventajas sobre configuración manual en la consola de AWS:
  - El mismo código genera exactamente la misma infraestructura (instancias, recursos, servicios, etc)
  - Despliega 1 o 100 instancias con el mismo esfuerzo
  - Usa Git para rastrear cambios y revertir errores
  - El código describe la infraestructura. No más `.txt` que describe cómo levantar la infra paso a paso

  #linear.callout(title: [Instalación])[
    Descarga el Terraform CLI desde: #link("https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli")[developer.hashicorp.com/terraform/install-cli]
  ]
]

#linear.slide(
  title: [Terraform],
  subtitle: [Conceptos de red en AWS],
)[
  #linear.data-table(
    headers: ("Componente", "Descripción"),
    column-widths: (20%, 80%),
    rows: (
      [#raw("VPC")],
      [Red virtual aislada donde vivirán tus recursos. Cada VPC es independiente y segura],
      [#raw("Subnet")],
      [Segmento de red dentro de una VPC. Necesitamos al menos una subnet pública con acceso a internet],
      [#raw("Internet Gateway")],
      [Permite comunicación entre tu VPC e internet. Se asocia a la VPC para enrutar tráfico externo],
      [#raw("Route Table")],
      [Define reglas de enrutamiento del tráfico dentro de la VPC y hacia internet],
      [#raw("Security Group")],
      [Firewall virtual que controla tráfico entrante y saliente de los recursos dentro de la VPC],
    ),
  )

  Estos componentes se crean en orden: VPC, Internet Gateway, Subnets, Route Tables, Security Groups
]


#linear.slide(
  title: [Terraform],
  subtitle: [Configuración básica de VPC e Internet Gateway],
)[
  #linear.two-columns(
    split: 55%,
    [
      Primero definimos el proveedor (AWS) y creamos nuestra red privada (VPC) con su gateway para acceso a internet.
      #v(1em)
      #block(width: 100%)[
        ```hcl
        provider "aws" {
          region = "us-east-2"
        }

        resource "aws_vpc" "default" {
          cidr_block           = "10.0.0.0/16"
          enable_dns_support   = true
          enable_dns_hostnames = true
          tags = { Name = "Proyecto1_EC2_VPC" }
        }

        resource "aws_internet_gateway" "default" {
          vpc_id = aws_vpc.default.id
          tags = { Name = "Proyecto1_EC2_IGW" }
        }
        ```
      ]
    ],
    [
      *¿Qué hace cada recurso?*
      #v(1em)
      - provider: Especifica la región en AWS, en este caso, us-east-2
      - aws_vpc: Crea una red privada con rango de IPs 10.0.0.0/16 (65,536 IPs disponibles)
      - enable_dns: Permite resolución de nombres DNS dentro de la VPC
      - aws_internet_gateway: Conecta la VPC a internet
    ],
  )
]

#linear.slide(
  title: [Terraform],
  subtitle: [Subnets y enrutamiento],
)[
  Creamos subnets públicas y configuramos las rutas para que el tráfico salga a internet.

  El siguiente código define una subnet pública con el rango de IPs 10.0.1.0/24 y la asocia con la route table que dirige todo el tráfico de internet al Internet Gateway.

  #block(width: 100%)[
    ```hcl
    resource "aws_subnet" "subnet1" {
      vpc_id                  = aws_vpc.default.id
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
      tags = { Name = "Django_Public_Subnet_1" }
    }

    resource "aws_route_table" "public" {
      vpc_id = aws_vpc.default.id
      route {
        cidr_block = "0.0.0.0/0"  # Todo el tráfico de internet
        gateway_id = aws_internet_gateway.default.id
      }
      tags = { Name = "Django_Public_RT" }
    }

    resource "aws_route_table_association" "subnet1" {
      subnet_id      = aws_subnet.subnet1.id
      route_table_id = aws_route_table.public.id
    }
    ```
  ]
]

#linear.slide(
  title: [Terraform],
  subtitle: [Grupos de seguridad y firewall],
)[
  Definimos qué tráfico puede entrar y salir de nuestra instancia EC2.

  #block(width: 100%)[
    ```hcl
    resource "aws_security_group" "ec2_sg" {
      name        = "django_ec2_sg"
      description = "Security group para instancia Django"
      vpc_id      = aws_vpc.default.id

      # Tráfico entrante (ingress)
      ingress {
        description = "HTTP desde internet"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Cualquier IP
      }

      ingress {
        description = "SSH para administración"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      # Tráfico saliente (egress)
      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"  # Todos los protocolos
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
    ```
  ]
]

#linear.slide(
  title: [Terraform: IAM Role para EC2],
  subtitle: [Permisos para acceder a ECR],
)[
  La instancia EC2 necesita permisos para descargar imágenes Docker desde ECR (Elastic Container Registry).

  #block(width: 100%)[
    ```hcl
    resource "aws_iam_role" "ec2_role" {
      name = "django_ec2_ecr_role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = { Service = "ec2.amazonaws.com" }
        }]
      })
    }

    resource "aws_iam_role_policy_attachment" "ecr_read" {
      role       = aws_iam_role.ec2_role.name
      policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    }

    resource "aws_iam_instance_profile" "ec2_profile" {
      name = "django_ec2_profile"
      role = aws_iam_role.ec2_role.name
    }
    ```
  ]

  El *instance profile* permite que EC2 asuma el rol y use sus permisos.
]

#linear.slide(
  title: [Terraform: Instancia EC2],
  subtitle: [El servidor que ejecuta Django],
)[
  Creamos la instancia EC2 que ejecutará nuestro contenedor Django.

  #block(width: 100%)[
    ```hcl
      resource "aws_instance" "web" {
        ami                         = "ami-0c101f26f147fa7fd"  # Amazon Linux 2023
        instance_type               = "t3.micro"  # Free tier eligible
        subnet_id                   = aws_subnet.subnet1.id
        vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
        associate_public_ip_address = true
        iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
        user_data_replace_on_change = true

        tags = { Name = "Django_Web_Server" }

        user_data = <<-EOF
          #!/bin/bash
          # ... (ver siguiente slide)
        EOF
      }
    ```
  ]

  *Parámetros clave:*
  - *ami:* Amazon Machine Image (sistema operativo base)
  - *user_data:* Script bash que se ejecuta al iniciar la instancia
  - *user_data_replace_on_change:* Recrea la instancia si cambia el script
]

#linear.slide(
  title: [User Data Script],
  subtitle: [Configuración automática al arrancar],
)[
  El script `user_data` automatiza la configuración del servidor:

  #block(width: 100%)[
    ```bash
    #!/bin/bash
    set -e  # Detener si hay errores

    # 1. Actualizar sistema e instalar dependencias
    yum update -y
    yum install -y docker aws-cli
    service docker start

    # 2. Autenticar con ECR
    aws ecr get-login-password --region us-east-1 | \
      docker login --username AWS --password-stdin <TU_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

    # 3. Descargar imagen Docker desde ECR
    docker pull <TU_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/django-ec2-complete:latest

    # 4. Ejecutar contenedor
    docker run -d -p 80:8080 \
      --name django-app \
      --restart unless-stopped \
      --env SECRET_KEY=${var.secret_key} \
      <TU_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/django-ec2-complete:latest
    ```
  ]

  El contenedor expone el puerto 8080 internamente y se mapea al puerto 80 del servidor (HTTP estándar).
]

#linear.slide(
  title: [Variables en Terraform],
  subtitle: [Valores parametrizables],
)[
  Define variables para valores sensibles o que cambien entre entornos:

  #block(width: 100%)[
    ```hcl
    variable "secret_key" {
      description = "Django SECRET_KEY"
      type        = string
      sensitive   = true  # No se muestra en logs
    }

    variable "aws_region" {
      description = "AWS region"
      type        = string
      default     = "us-east-1"
    }
    ```
  ]

  Crea un archivo `terraform.tfvars` (no lo subas a Git):
  #block(width: 100%)[
    ```hcl
    secret_key = "tu-clave-secreta-super-segura"
    aws_region = "us-east-1"
    ```
  ]
]

#linear.slide(
  title: [Aplicar la infraestructura],
  subtitle: [Comandos de Terraform],
)[
  *Flujo de trabajo básico:*

  #block(width: 80%)[
    ```bash
    # 1. Inicializar Terraform (descargar providers)
    terraform init

    # 2. Ver qué cambios se aplicarán (sin ejecutar)
    terraform plan

    # 3. Aplicar cambios
    terraform apply
    ```
  ]

  Terraform te muestra un resumen de los recursos que creará:
  - VPC, subnets, Internet Gateway
  - Security groups, IAM roles
  - Instancia EC2

  Escribe `yes` para confirmar. El proceso toma 2-5 minutos.

  #linear.callout(title: [Verificación])[
    Ve a la consola de AWS → EC2 → Instances. Verás tu servidor con estado "running". Copia la IP pública y accede via HTTP.
  ]
]

#linear.slide(
  title: [Output values],
  subtitle: [Obtener información útil],
)[
  Define outputs para mostrar información importante después del apply:

  #block(width: 100%)[
    ```hcl
    output "instance_public_ip" {
      description = "IP pública de la instancia EC2"
      value       = aws_instance.web.public_ip
    }

    output "instance_url" {
      description = "URL de la aplicación"
      value       = "http://${aws_instance.web.public_ip}"
    }

    output "vpc_id" {
      description = "ID de la VPC creada"
      value       = aws_vpc.default.id
    }
    ```
  ]

  Después de `terraform apply`, verás estos valores automáticamente. Úsalos para acceder a tu aplicación.
]

#linear.slide(
  title: [Destruir infraestructura],
  subtitle: [Limpieza de recursos],
)[
  Cuando ya no necesites la infraestructura:

  #block(width: 80%)[
    ```bash
    terraform destroy
    ```
  ]

  Terraform eliminará todos los recursos en orden inverso a su creación. *Esto es irreversible.*

  *Recomendación:* Usa `terraform plan -destroy` primero para ver qué se eliminará.

  #linear.callout(title: [Importante])[
    AWS cobra por recursos activos (instancias, IPs elásticas, etc.). Destruye recursos que no uses para evitar costos.
  ]
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
  subtitle: [Siéntete libre de preguntar],
)
