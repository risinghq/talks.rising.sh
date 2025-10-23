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

#linear.section-slide[Proyecto \#0: Django (boilerplate)]

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

  #image("img/server.png", width: 70%)

  Finalmente, podemos probar en el navegador:
  #link("http://127.0.0.1:8000/")[http://127.0.0.1:8000/]. Si aparece la página de inicio de Django, el entorno está correctamente configurado.

  Para guardar las dependencias:

  ```bash
  pip freeze > requirements.txt
  ```

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
  FROM python:3.14.0-slim

  # Puerto en el que el contenedor expone a la aplicación
  ENV PORT=8080

  # Carpeta de trabajo dentro del contenedor
  WORKDIR /app

  # Copia todo el contenido de la carpeta "proyecto1" (directorio actual)
  # al directorio /app dentro del contenedor Docker.
  COPY . /app/
  # Instalar dependencias
  RUN pip install --upgrade pip && pip install -r requirements.txt

  CMD ["gunicorn", "proyecto1.wsgi:application", "--bind", "0.0.0.0:8080"]
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

  Hoy lo haremos directamente con código. Primero, asegúrate de tener instalado *AWS CLI* (https://awscli.amazonaws.com/AWSCLIV2.msi) en tu PC:
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
  #v(0.25em)
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
  Antes de revisar el código, veamos una analogía para entender cómo funciona una VPC en AWS.

  Piensa que vas a construir un edificio para tu aplicación web. Primero necesitas un terreno delimitado, eso es tu VPC: tu espacio privado en AWS. Dentro de ese terreno, divides el espacio en secciones o subnets para organizar mejor tus recursos. Luego instalas una puerta de entrada, el Internet Gateway, que conecta tu edificio con el mundo exterior. Para que la gente sepa cómo moverse, pones señalética o route tables que indican las rutas. Y finalmente, implementas un sistema de seguridad con security groups que controlan quién puede entrar y salir.

  #linear.callout(title: [Orden de creación])[
    Estos componentes se crean en secuencia: Primero VPC, luego Internet Gateway, Subnets, Route Tables, Security Groups
  ]
]

#linear.slide(
  title: [Terraform],
  subtitle: [VPC],
)[
  #linear.two-columns(
    split: 45%,
    [
      *¿Qué es CIDR?*

      `10.0.0.0/16` significa que 10.0.0.0 es la dirección base y /16 indica que los primeros 16 bits son fijos. El resultado son 65,536 IPs disponibles (desde 10.0.0.0 hasta 10.0.255.255).

      #v(1em)
      *¿Por qué DNS?*

      `enable_dns_support` permite resolución de nombres y `enable_dns_hostnames` asigna nombres DNS a recursos. Esto permite usar nombres como `mi-base-datos.internal` en vez de IPs.
    ],
    [
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

      El Internet Gateway se asocia a la VPC y permite que los recursos dentro puedan comunicarse con internet.
    ],
  )
]

#linear.slide(
  title: [Terraform],
  subtitle: [Subnets públicos],
)[
  Una subnet puede ser pública o privada según su configuración de enrutamiento.

  #linear.two-columns(
    split: 50%,
    [
      Subnet Pública (nuestro caso):
      - Tiene ruta al Internet Gateway
      - Las instancias pueden tener IP pública
      - Usa: servidores web, APIs

      Ignoraremos el caso de subnet privada ya que no es necesario para nuestro proyecto.

      #v(1em)
      `map_public_ip_on_launch = true` hace que cada instancia en esta subnet reciba automáticamente una IP pública.
    ],
    [
      ```hcl
      resource "aws_subnet" "subnet1" {
        vpc_id                  = aws_vpc.default.id
        cidr_block              = "10.0.1.0/24"
        availability_zone       = "us-east-1a"
        map_public_ip_on_launch = true
        tags = { Name = "Django_Public_Subnet_1" }
      }
      ```

      Availability Zone: AWS divide cada región en múltiples zonas físicamente separadas. Esto da resiliencia ante fallos de hardware (véase el caso de hace unos días cuando us-east-1 cayó).
    ],
  )
]

#linear.slide(
  title: [Terraform],
  subtitle: [Route Tables],
)[
  *¿Cómo funciona el enrutamiento?* Cuando un paquete sale de tu instancia EC2, la Route Table decide a dónde enviarlo:

  ```hcl
  resource "aws_route_table" "public" {
    vpc_id = aws_vpc.default.id
    route {
      cidr_block = "0.0.0.0/0"  # Cualquier destino en internet
      gateway_id = aws_internet_gateway.default.id
    }
    tags = { Name = "Django_Public_RT" }
  }
  ```

  Es decir: "Si el destino NO está en mi VPC (10.0.0.0/16), envía el paquete al Internet Gateway"

  #v(1em)
  Asociación: Conectar la subnet con la route table:
  ```hcl
  resource "aws_route_table_association" "subnet1" {
    subnet_id      = aws_subnet.subnet1.id
    route_table_id = aws_route_table.public.id
  }
  ```

  Sin esta asociación, la subnet no sabe cómo enrutar el tráfico.
]

#linear.slide(
  title: [Terraform],
  subtitle: [Security Groups],
)[
  Puedes pensar en los Security Groups como guardias de seguridad que inspeccionan cada conexión.

  Reglas de entrada (ingress):
  - Puerto 80 (HTTP): Para que los usuarios accedan a tu sitio web
  - Puerto 22 (SSH): Para que TÚ puedas conectarte y administrar el servidor

  Regla de salida (egress):
  - Todos los puertos: El servidor puede iniciar conexiones a cualquier destino (descargar paquetes, actualizar Docker, etc.)

  #v(1em)
  #linear.callout(title: [Importante])[
    `0.0.0.0/0` significa "cualquier IP". En producción, restringe SSH a tu IP o VPN corporativa.
  ]
]

#linear.slide(
  title: [Terraform],
  subtitle: [Security Groups],
)[
  ```hcl
  resource "aws_security_group" "ec2_sg" {
    name   = "django_ec2_sg"
    vpc_id = aws_vpc.default.id

    ingress {
      description = "HTTP desde internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "SSH para admin"
      from_port   = 22
      to_port     = 22
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
]

#linear.slide(
  title: [Terraform],
  subtitle: [Permisos en AWS],
)[
  Problema: Tu instancia EC2 necesita descargar la imagen Docker desde ECR. ¿Cómo le damos permiso?

  Solución: IAM Roles, identidades con permisos específicos que los servicios pueden asumir.

  #linear.two-columns(
    split: 50%,
    [
      Flujo de permisos:
      1. Role: Define QUÉ puede hacer (leer ECR)
      2. Assume Role Policy: Define QUIÉN puede usarlo (servicio EC2)
      3. Instance Profile: Adjunta el role a la instancia

      #v(1em)
      La política `AmazonEC2ContainerRegistryReadOnly` es gestionada por AWS y da permisos de solo lectura a ECR.
    ],
    [
      ```hcl
      resource "aws_iam_role" "ec2_role" {
        name = "django_ec2_ecr_role"
        assume_role_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "ec2.amazonaws.com"
            }
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
    ],
  )
]

#linear.slide(
  title: [Terraform],
  subtitle: [Instancia EC2],
)[
  Finalmente, creamos el servidor que ejecutará Django:

  ```hcl
  resource "aws_instance" "web" {
    ami                         = "ami-0c101f26f147fa7fd"  # Amazon Linux 2023
    instance_type               = "t3.micro"
    subnet_id                   = aws_subnet.subnet1.id
    vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
    associate_public_ip_address = true
    iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
    user_data_replace_on_change = true
    tags = { Name = "Django_Web_Server" }

    user_data = <<-EOF
      #!/bin/bash
      # ... (configuración automática)
    EOF
  }
  ```
]

#linear.slide(
  title: [Terraform],
  subtitle: [Parámetros de EC2],
)[
  #linear.data-table(
    headers: ("Parámetro", "¿Qué hace?", "¿Por qué este valor?"),
    column-widths: (25%, 35%, 40%),
    rows: (
      [ami],
      [Amazon Machine Image - el "sistema operativo" base],
      [Amazon Linux 2023 es optimizado para AWS, incluye AWS CLI y Docker pre-instalable],
      [instance_type],
      [Capacidad de CPU y RAM],
      [`t3.micro`: 2 vCPUs, 1GB RAM. Suficiente para Django y free tier],
      [subnet_id],
      [Dónde vive la instancia],
      [La subnet pública que creamos antes con acceso a internet],
      [iam_instance_profile],
      [Permisos de la instancia],
      [Le da acceso a ECR para descargar la imagen Docker],
      [user_data],
      [Script de inicialización],
      [Automatiza la instalación de Docker y deployment de la app],
      [user_data_replace_on_change],
      [Recrear si cambia user_data],
      [`true`: Si modificas el script, Terraform destruye y recrea la instancia],
    ),
  )
]

#linear.slide(
  title: [Terraform],
  subtitle: [Automatizando el proceso],
)[
  El script `user_data` se ejecuta UNA VEZ cuando la instancia inicia por primera vez.

  Pasos que automatiza:
  1. Actualizar el sistema e instalar Docker + AWS CLI
  2. Autenticar con ECR usando credenciales de IAM
  3. Descargar la imagen Docker desde tu repositorio privado
  4. Ejecutar el contenedor exponiendo el puerto 80

  #v(1em)
  #linear.callout(title: [Concepto clave])[
    `set -e` al inicio hace que el script se detenga si cualquier comando falla. Esto evita que sigas ejecutando comandos cuando algo salió mal.
  ]

  Ver código completo en el repo. Los puntos críticos son `docker run -d -p 80:8080` que mapea puerto 8080 del contenedor al 80 del host, `--restart unless-stopped` reinicia el contenedor automáticamente si falla, y `--env SECRET_KEY=${var.secret_key}` inyecta variables de entorno seguras.
]

#linear.slide(
  title: [Terraform],
  subtitle: [Parametrización],
)[
  ¿Por qué usar variables? Por seguridad, valores sensibles no van en el código. Te da flexibilidad para usar el mismo código en dev, staging y producción. Y facilita la colaboración porque cada desarrollador usa sus propias credenciales.

  #linear.two-columns(
    split: 50%,
    [
      Declaración en `variables.tf`:
      ```hcl
      variable "secret_key" {
        description = "Django SECRET_KEY"
        type        = string
        sensitive   = true  # Oculta en logs
      }

      variable "aws_region" {
        description = "AWS region"
        type        = string
        default     = "us-east-1"
      }
      ```
    ],
    [
      Valores en `terraform.tfvars`:
      ```hcl
      secret_key = "tu-clave-super-secreta"
      aws_region = "us-east-1"
      ```

      #linear.callout(title: [¡IMPORTANTE!])[
        Agrega `terraform.tfvars` a `.gitignore`. Nunca commitees secretos.
      ]
    ],
  )

  Uso en código: `${var.secret_key}` accede al valor de la variable.
]

#linear.slide(
  title: [Terraform],
  subtitle: [Workflow o modo de trabajo],
)[
  Los 3 comandos esenciales:

  ```bash
  terraform init    # Descarga providers y módulos
  terraform plan    # Vista previa de cambios (sin aplicar)
  terraform apply   # Aplica cambios (requiere confirmación)
  ```

  #v(1em)
  ¿Qué pasa cuando ejecutas `apply`? Terraform lee tu código `.tf`, compara con el estado actual en `terraform.tfstate`, calcula qué crear, modificar o eliminar, te muestra un plan y pide confirmación, ejecuta las operaciones contra la API de AWS, y actualiza el archivo de estado.

  #linear.callout(title: [Estado de Terraform])[
    `terraform.tfstate` es crucial, guarda el mapeo entre tu código y los recursos reales en AWS. Protégelo y nunca lo edites manualmente.
  ]
]

#linear.slide(
  title: [Terraform],
  subtitle: [Outputs],
)[
  Los outputs muestran información relevante automáticamente después de `apply`:

  ```hcl
  output "instance_public_ip" {
    description = "IP pública de la instancia EC2"
    value       = aws_instance.web.public_ip
  }

  output "instance_url" {
    description = "URL de la aplicación"
    value       = "http://${aws_instance.web.public_ip}"
  }
  ```

  Resultado en terminal después de apply:
  ```
  Outputs:
  instance_public_ip = "18.220.45.123"
  instance_url = "http://18.220.45.123"
  ```

  Copia la URL y ábrela en tu navegador, tu aplicación Django está corriendo.

  Tip: También puedes ejecutar `terraform output` en cualquier momento para ver los valores.
]

#linear.slide(
  title: [Terraform],
  subtitle: [Modificar infra],
)[
  Escenario: Quieres abrir el puerto 8000 para debugging.

  Edita `main.tf` y agrega una regla ingress:
  ```hcl
  ingress {
    description = "Django dev server"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ```

  Ejecuta `terraform plan` y verás que modificará el security group.

  Aplica `terraform apply` y Terraform actualiza solo ese recurso.

  #v(1em)
  #linear.callout(title: [Terraform es inteligente])[
    No recrea todo desde cero. Solo modifica los recursos que cambiaron. Esto es gracias al archivo de estado.
  ]
]

#linear.slide(
  title: [Terraform],
  subtitle: [Limpieza de recursos],
)[
  Cuando termines con el proyecto:

  ```bash
  terraform destroy
  ```

  Terraform eliminará todos los recursos en orden inverso a su creación (respetando dependencias).

  #v(1em)
  Orden de destrucción:
  - Instancia EC2
  - Security Groups
  - Route Table Associations
  - Route Tables
  - Subnets
  - Internet Gateway
  - VPC

  #v(1em)
  #linear.callout(title: [Costos])[
    AWS cobra por recursos activos. Si no destruyes la infraestructura, seguirás pagando por la instancia EC2, IP pública, etc. Destruye lo que no uses.
  ]

  Recomendación: `terraform plan -destroy` te muestra qué se eliminará sin hacerlo.
]

#linear.section-slide[Dominio y HTTPS]

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
