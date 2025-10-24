#import "linear/main.typ" as linear
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

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

  COPY ./requirements.txt /app/
  # Instalar dependencias
  RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

  # Copiar el proyecto
  COPY ./proyecto1 /app

  EXPOSE ${PORT}
  CMD ["gunicorn", "proyecto1.wsgi:application", "--bind", "0.0.0.0:8080"]
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
  docker kill <container_id>
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
    image("img/awscli.png", width: 55%),
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
      aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin <TU_URI>.dkr.ecr.us-east-2.amazonaws.com/proyecto1-ec2
      ```
    ]

  3. Etiquetar la imagen:

    #block[
      ```bash
      docker tag proyecto1-ec2:latest <TU_URI>.dkr.ecr.us-east-2.amazonaws.com/proyecto1-ec2:latest
      ```
    ]

  4. Subir la imagen al repositorio de ECR:

    #block[
      ```bash
      docker push <TU_URI>.dkr.ecr.us-east-2.amazonaws.com/proyecto1-ec2:latest
      ```
    ]

    Este proceso puede que tome un par de minutos. Puedes ir por un café o tomar un descanso.

    Para verificar este proceso, puedes dirigirte a la consola de AWS y buscar la imagen en el repositorio de ECR: #link("https://us-east-2.console.aws.amazon.com/ecr/home?region=us-east-2#")[https://us-east-2.console.aws.amazon.com/ecr/home?region=us-east-2#]

    #figure(image("img/aws-ecr.png", width: 70%))
]

#linear.focus-slide(text-size: 25pt)[
  A continuación, configuraremos un servidor en AWS, descargaremos la imagen y verificaremos que el proyecto Django se ejecute al acceder a la dirección IP del servidor... Pero antes...
]

#linear.section-slide[Herramienta \#2: Terraform]

#linear.slide(
  title: [Terraform],
  subtitle: [¿Por qué lo vamos a usar?],
)[
  Imagina que configuraste tu aplicación Django _manualmente_ en AWS:

  - Hiciste clic en 47 botones diferentes en la consola
  - Configuraste redes, subnets, security groups...
  - Todo funcionó perfectamente

  Genial, *pero ahora necesitas:*

  - Replicarlo en producción (a escala, es decir, en múltiples regiones, cuentas e instancias)
  - Que tu compañero de trabajo configure su entorno
  - Documentar qué hiciste exactamente para que puedas replicar el proceso

  #linear.callout[
    Lo más probable es que hayas olvidado qué hiciste en el paso 23. Tu compañero de trabajo configurará algo distinto y, sin darse cuenta, generará inconsistencias o errores difíciles de detectar y corregir (technical debt).
  ]
]

#linear.slide(
  title: [Terraform],
  subtitle: [La solución es Infraestructura como Código (IaC)],
)[
  Terraform te permite definir y gestionar tu infraestructura mediante archivos *.tf*. Un ejemplo mínimo:

  ```hcl
  resource "aws_instance" "web" {
    ami           = "ami-0c101f26f147fa7fd"   // ID de la imagen de Amazon Linux 2023
    instance_type = "t3.micro"                // 1GB RAM, 2 vCPUs
  }
  ```

  *Ventajas:*
  - El mismo código genera el mismo resultado en AWS, Google Cloud, Azure, etc.
  - Versionado con Git (puedes ver qué cambió, cuándo y por qué; útil en caso de bugs o rollbacks).
  - Infraestructura replicable en segundos (no en 435345 clics) usando comandos como `terraform apply`
  - El código ES la documentación

  #linear.callout(title: [Descarga e instalación])[
    https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform
  ]
]

#linear.slide(
  title: [Terraform],
  subtitle: [Tu flujo de trabajo al final del workshop],
)[
  #set enum(spacing: 1em)
  #align(center)[
    #figure(
      image("img/flow-diagram.png", width: 50%),
    )
  ]

  *Nuestro objetivo final es:*

  1. Migrar Django de ejecución local [ver pág. 11] a un contenedor Docker (algunos lo llaman dockerizar)
  2. Crear la imagen Docker y subirla a AWS ECR (Elastic Container Registry) [ver pág. 22]
  3. Utilizar Terraform para implementar un servidor EC2 que descargue y ejecute tu imagen (en esta sección veremos cómo hacerlo)
  4. Tu aplicación estará disponible a través de una IP pública (podrás acceder a ella desde tu navegador)
]

#linear.slide(
  title: [Terraform],
  subtitle: [Componentes de AWS],
)[
  Desplegar (deploy) significa crear la infraestructura donde se alojará tu aplicación. No entraremos en demasiados detalles de cómo funciona Terraform, pero podemos verlo como una analogía a la construcción de un edificio. No puedes construir sin terreno; en AWS pasa lo mismo. El proceso va así:

  #v(0.5em)
  #linear.two-columns(
    split: 50%,
    [
      *VPC (Virtual Private Cloud)* [1]
      #v(0.25em)
      Tu terreno delimitado en AWS. Todo vive aquí dentro.

      #v(1em)

      *Subnets* [2]
      #v(0.25em)
      Zonas (divisiones) dentro de la VPC (terreno) para organizar recursos.

      #v(1em)

      *Internet Gateway* [3]
      #v(0.25em)
      La puerta de entrada que conecta tu edificio con internet.
    ],
    [
      *Route Tables* [4]
      #v(0.25em)
      Definen las rutas del tráfico dentro de la red.

      #v(1em)

      *Security Groups* [5]
      #v(0.25em)
      Puedes verlo como guardias de seguridad que controlan quién puede entrar y por dónde.

      #v(1em)

      *EC2 Instance* [6]
      #v(0.25em)
      El servidor donde corre tu aplicación. En este caso, Django.
    ],
  )

  #v(1em)

  Terraform creará todo esto automáticamente siguiendo el orden correcto [1, 2, 3, 4, 5, 6].
]

#linear.focus-slide[
  Suficiente para empezar a ver código...
]

#linear.slide(
  title: [Terraform],
  subtitle: [AWS: VPC [1]],
)[
  Primero, tenemos que indicar a Terraform que utilizaremos AWS como proveedor:

  #block(width: 50%)[
    ```hcl
    provider "aws" {
      region = "us-east-2"
    }

    resource "aws_vpc" "default" {
      cidr_block = "10.0.0.0/16"
      enable_dns_support   = true
      enable_dns_hostnames = true

      tags = { Name = "Django_VPC" }
    }
    ```
  ]

  En el segundo bloque, definimos nuestra *red privada* (VPC). La opción `enable_dns_support` activa la resolución de nombres dentro de la VPC, mientras que `enable_dns_hostnames` permite asignar nombres DNS internos a las instancias, de modo que podamos referirnos a ellas con nombres como `db.internal` en lugar de direcciones IP (mucho más fácil de recordar).
]

#linear.slide(
  title: [Terraform],
  subtitle: [AWS: Internet Gateway [3]],
)[
  Luego, necesitamos crear un Internet Gateway para permitir que los recursos dentro de nuestra VPC tengan acceso a internet (por ejemplo, para actualizar paquetes o exponer una app web):

  #block(width: 50%)[
    ```hcl
    resource "aws_internet_gateway" "default" {
      vpc_id = aws_vpc.default.id

      tags = {
        Name = "Django_IGW"
      }
    }
    ```
  ]

  #v(1em)

  Ojito a `aws_vpc.default.id`. Terraform entiende las dependencias. No puedes crear el gateway sin VPC primero.
]

#linear.slide(
  title: [Terraform],
  subtitle: [AWS: Subnets [2]],
)[
  Creamos una subnet pública (accesible desde internet):
  ```hcl
  resource "aws_subnet" "public" {
    vpc_id                  = aws_vpc.default.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-east-2a"

    map_public_ip_on_launch = true  # Cada instancia recibe IP pública automáticamente

    tags = {
      Name = "Django_Public_Subnet"
    }
  }
  ```
]

#linear.slide(
  title: [Terraform],
  subtitle: [AWS: Route Tables [4]],
)[
  Luego configuramos la tabla de rutas para que la subnet pública tenga salida a internet:

  ```hcl
  resource "aws_route_table" "public" {
    vpc_id = aws_vpc.default.id                     # Mismo ID que la VPC que creamos (pag. 45)

    route {
      cidr_block = "0.0.0.0/0"                      # Tráfico a cualquier IP es permitido
      gateway_id = aws_internet_gateway.default.id  # Sale por el Gateway que definimos (pag. 46)
    }

    tags = {
      Name = "Django_Route_Table"
    }
  }
  ```

  Traducción: "Si el destino NO está dentro de la VPC (10.0.0.0/16), envíalo a internet"
]

#linear.slide(
  title: [Terraform],
  subtitle: [AWS: Security Groups [5] (ingress)],
)[
  Creamos un grupo de seguridad que define qué tráfico entra a nuestras instancias EC2 dentro de la VPC:

  ```hcl
  resource "aws_security_group" "ec2_sg" {
    vpc_id = aws_vpc.default.id

    # Permitir tráfico HTTP desde cualquier lugar
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ```

  También es posible definir una regla para permitir que nos conectemos a la instancia a través de SSH desde nuestra IP pública.
]

#linear.slide(
  title: [Terraform],
  subtitle: [AWS: Security Groups [5] (egress)],
)[
  Ahora definimos las reglas de salida (egress), que controlan el tráfico desde nuestras instancias hacia otros destinos (por ejemplo, internet):

  ```hcl
  resource "aws_security_group" "ec2_sg" {
    vpc_id = aws_vpc.default.id

    egress {
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"              # Todos los protocolos
      cidr_blocks = ["0.0.0.0/0"]     # Cualquier destino en la red
    }
  }
  ```

  Aquí se muestran `ingress` y `egress` por separado para mayor claridad, pero en la práctica ambas reglas se definen dentro del mismo recurso.
]

#linear.slide(
  title: [Terraform],
  subtitle: [AWS: EC2 Instance [6] (roles IAM)],
)[
  Nuestra instancia EC2 necesita permisos para descargar imágenes Docker desde ECR (ver pag. 35). Para ello, creamos un rol IAM ( `aws_iam_role`) que la instancia puede asumir.
  Este rol otorga credenciales temporales con los permisos necesarios.

  ```hcl
  resource "aws_iam_role" "ec2_ecr" {
    name = "ec2_ecr_access"

    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      }]
    })
  }
  ```
]


#linear.slide(
  title: [Terraform],
  subtitle: [AWS: EC2 Instance [6] (políticas y perfil)],
)[
  Ahora adjuntamos una política de solo lectura en ECR al rol y creamos un perfil de instancia que EC2 utilizará al iniciarse.

  ```hcl
  resource "aws_iam_role_policy_attachment" "ecr_read" {
    role       = aws_iam_role.ec2_ecr.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  resource "aws_iam_instance_profile" "ec2_profile" {
    name = "ec2_profile"
    role = aws_iam_role.ec2_ecr.name
  }
  ```

  *Qué hace cada recurso:*

  `aws_iam_role_policy_attachment`: da permisos de solo lectura a ECR (permisos mínimos para mayor seguridad).

  `aws_iam_instance_profile`: permite que la instancia EC2 use el rol creado en el paso anterior.
]

#linear.slide(
  title: [Terraform],
  subtitle: [AWS: EC2 Instance [6] (creación - parte 1)],
)[
  Finalmente, creamos la instancia EC2 donde se ejecutará nuestra aplicación Django:

  ```hcl
  resource "aws_instance" "django" {
    ami                    = "ami-0c101f26f147fa7fd"    # Amazon Linux 2023
    instance_type          = "t3.micro"                 # (1GB RAM, 2 vCPUs)
    subnet_id              = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.django.id]
    iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

    user_data = <<-EOF
      # Aquí va el script que se ejecuta al iniciar la instancia
    EOF

    tags = {
      Name = "Django_Server"
    }
  }
  ```

  Esta instancia utilizará el rol IAM configurado para obtener acceso de solo lectura a ECR.
]

#linear.slide(
  title: [Terraform],
  subtitle: [AWS: EC2 Instance [6] (creación - parte 2)],
)[
  Este script se ejecuta UNA VEZ cuando la instancia inicia (user_data):

  ```bash
  #!/bin/bash
  set -e  # Detener si algo falla

  # 1. Instalar Docker
  yum update -y && yum install -y docker && service docker start

  # 2. Instalar AWS CLI
  yum install -y aws-cli

  # 3. Login a ECR
  aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin YOUR_ECR_REGISTRY_URL

  # 4. Descargar y ejecutar tu imagen Django
  docker pull YOUR_ECR_REGISTRY_URL/django-app:latest
  docker run -d -p 80:8080 --restart unless-stopped -e SECRET_KEY=${var.secret_key} YOUR_ECR_REGISTRY_URL/django-app:latest
  ```
]

#linear.focus-slide(text-size: 25pt)[
  _¿Y si no uso Terraform?_ AWS tiene muchos componentes. Ya sea con Terraform o desde la consola, debes crear cada uno: red, VPC, gateway, subredes, grupos de seguridad, servidor y roles de IAM. Revisa e investiga cada parte para entender su función.
]

#linear.focus-slide[
  _Recomendación_: No memorices el proceso. Los archivos .tf estarán en el repositorio 🐧
]

#linear.slide(
  title: [Terraform],
  subtitle: [AWS: En resumen...],
)[
  Repasando una última vez, acabas de definir la infraestructura AWS para desplegar tu aplicación Django containerizada. La infra quedaría así:

  *Redes*: Un VPC con DNS interno habilitado. Subred pública en zona `us-east-2a` con auto-asignación de IPs públicas. Internet Gateway conecta la VPC a internet, y el route table dirige todo el tráfico no-local ( `0.0.0.0/0`) hacia el IGW (Internet Gateway).

  *Seguridad*: Security group actúa como firewall permitiendo tráfico HTTP entrante (puerto 80) desde cualquier origen y salida completa para descargas y conexiones externas. Rol IAM con política `AmazonEC2ContainerRegistryReadOnly` permite acceso a ECR sin credenciales hardcodeadas, asociado vía instance profile.

  *Servidor*: Tipo `t3.micro` basada en Amazon Linux 2023 ( `ami-0c101f26f147fa7fd`). Script `user_data` ejecuta al inicio e instala Docker, autentica contra ECR usando el rol IAM, y levanta el contenedor Django automáticamente.
]

#linear.focus-slide[
  _Tangente_: La seguridad es importante.
]

#linear.slide(
  title: [Terraform],
  subtitle: [Variables de entorno y secretos],
)[
  Cuando trabajamos con Terraform, tarde o temprano necesitamos usar credenciales sensibles (conocidas como secrets). Estas pueden ser contraseñas de base de datos, tokens de API o claves de acceso a AWS.

  Escribir tus credenciales directamente en el código es una mala práctica:

  ```hcl
  resource "aws_db_instance" "mydb" {
      engine         = "postgres"
      instance_class = "db.t3.micro"

      # 🚨 atención aquí:
      username       = "root"
      password       = "password123"
  }
  ```

  *Esto es inseguro*. Las credenciales quedarían expuestas en el código, en el `terraform.tfstate` y potencialmente en el historial de Git.
  Incluso si el repositorio es privado, una filtración o acceso local comprometería toda la infraestructura.
]

#linear.slide(
  title: [Terraform],
  subtitle: [Variables sensibles en Terraform],
)[
  Terraform permite declarar variables marcadas como *sensitive*, evitando que sus valores aparezcan en logs o salidas de comandos.

  ```hcl
  variable "username" {
    type        = string
    sensitive   = true
  }

  variable "password" {
    type        = string
    sensitive   = true
  }
  ```

  En lugar de valores literales, ahora usamos las referencias `var.username` y `var.password` dentro del recurso:

  ```hcl
  username = var.username
  password = var.password
  ```
]

#linear.slide(
  title: [Terraform],
  subtitle: [Usando variables de entorno],
)[
  Una forma simple es usar variables de entorno con el prefijo `TF_VAR_`. Terraform las detecta automáticamente.

  ```bash
  export TF_VAR_username="admin"
  export TF_VAR_password="supersecret"
  terraform apply
  ```

  En Windows (PowerShell):

  ```powershell
  Set-Item -Path env:TF_VAR_username -Value "admin"
  Set-Item -Path env:TF_VAR_password -Value "supersecret"
  ```

  Ahora, cuando ejecutes `terraform apply`, terraform leerá las variables de entorno `TF_VAR_username` y `TF_VAR_password` y usará sus valores respectivos.

  Este método evita incluir los valores en el código, pero no es completamente seguro ya que
  los valores quedarán *registrados en el historial* de la terminal o visibles a otros procesos del ordenador que uses.
]

#linear.slide(
  title: [Terraform],
  subtitle: [Usando archivos .tfvars locales],
)[
  Otra práctica habitual es crear un archivo `terraform.tfvars` con las variables reales:

  ```hcl
  username = "admin"
  password = "password123"
  ```

  Como este archivo no debe subirse al repositorio. Simplemente lo agregamos al `.gitignore`:

  ```
  terraform.tfvars
  *.tfstate
  *.tfstate.backup
  ```

  Es una opción simple y práctica para entornos locales o de desarrollo. Sin embargo, si trabajas en equipo, cada miembro debe gestionar su propio archivo y asegurarse de mantenerlo fuera del control de versiones. Además de que *no soluciona* los problemas que mencionamos antes (un proceso malicioso en tu ordenador podría leer tus secretos).
]

#linear.focus-slide[
  Todo eso se ve complicado, ¿AWS ofrece alguna forma de gestionar los secretos?
]

#linear.slide(
  title: [Terraform],
  subtitle: [AWS KMS (cifrado)],
)[
  Para entornos empresariales, se recomienda utilizar *AWS Key Management Service (KMS)* para el cifrado de secretos y datos sensibles. KMS permite gestionar claves de cifrado de forma centralizada y segura en AWS.

  Este servicio tiene un costo aproximado de \$1 USD mensual por clave KMS.

  Para usarlo, dirígete a https://us-east-2.console.aws.amazon.com/kms/home?region=us-east-2#/kms/home.

  En el panel, sigue estos pasos:

  #set enum(spacing: 1em)
  1. Selecciona "Create key"
  2. Configura la clave eligiendo "Symmetric" como _key type_ y "Encrypt and decrypt" como _key usage_
  3. Haz clic en "Next"

  #align(center)[
    #figure(
      image("img/aws-kms-1.png", width: 80%),
    )
  ]

  Asigna un nombre que te sirva para identificar a tu clave. En este ejemplo, utilizaremos "key-aws".

  #align(center)[
    #figure(
      image("img/aws-kms-2.png", width: 76%),
    )
  ]

  #align(center)[
    #figure(
      image("img/aws-kms-3.png", width: 76%),
    )
  ]

  En este paso, asegúrate de seleccionar el mismo usuario que creamos en la pag. 27 para los permisos.

  #align(center)[
    #figure(
      image("img/aws-kms-4.png", width: 76%),
    )
  ]

  Guarda el ID de la clave generada por KMS. Este ID será necesario en los siguientes pasos.

  == Cifrado de credenciales

  Crea un archivo con las credenciales sensibles. En este caso, `db-creds.yml`:

  #block(width: 60%)[
    ```yml
    username: root
    password: password123
    ```
  ]

  Utiliza AWS CLI para cifrar el archivo con la clave KMS creada:

  #block(width: 60%)[
    ```bash
    aws kms encrypt \
          --key-id <KEY_ID> \
          --region us-east-2 \
          --plaintext fileb://db-creds.yml \
          --output text \
          --query CiphertextBlob > db-creds.yml.enc
    ```
  ]

  Reemplaza `<KEY_ID>` con el ID de tu clave KMS del paso anterior. Si utilizas un nombre diferente para el archivo YAML, actualiza el comando correspondientemente.

  Tras ejecutar el comando, se generará el archivo cifrado `db-creds.yml.enc`. Este archivo puede compartirse de forma segura e incluso incluirse en los repositorios internos de tu empresa (¿recuerdas que añadimos archivos al .gitignore?).

  == Integración de AWS KMS con Terraform

  Para configurar Terraform y que descifre las credenciales durante `terraform apply`:

  ```hcl
  data "aws_kms_secrets" "creds" {
    secret {
      name    = "db"
      payload = file("${path.module}/db-creds.yml.enc")
    }
  }

  locals {
    db_creds = jsondecode(
      data.aws_kms_secrets.creds.secret[0].plaintext
    )
  }
  ```

  #colbreak()
  Ahora podemos actualizar el recurso de Terraform (revisa la pág. 57) para utilizar las credenciales descifradas:

  ```hcl
  resource "aws_example_instance" "mydb" {
    engine = "postgres"
    instance_class = "db.t3.micro"

    # Credenciales seguras mediante KMS:
    username = local.db_creds.username
    password = local.db_creds.password
  }
  ```

  Durante la ejecución de `terraform apply`, Terraform utilizará KMS para descifrar las credenciales y provisionar los recursos correspondientes.

  #linear.callout[
    Un problema con este método es que no podrás modificar manualmente el archivo `db-creds.yml.enc`. Existen herramientas que permiten hacerlo, pero quedan fuera del alcance de este workshop (puedes buscar *sops* si te interesa). Con lo visto hasta ahora debería ser suficiente para entender, de forma general, cómo manejar este proceso.
  ]
]

#linear.slide(
  title: [Terraform],
  subtitle: [AWS Secrets Manager],
)[
  *AWS Secrets Manager* ofrece una alternativa completamente gestionada. Los secretos se almacenan cifrados, pueden rotarse automáticamente y Terraform puede leerlos como datos:

  ```hcl
  data "aws_secretsmanager_secret_version" "creds" {
    secret_id = "db-creds"
  }
  locals {
    db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
  }
  ```

  Para crear un nuevo secreto, dirígete a la consola de AWS y busca "Secrets Manager". O haz click #link("https://us-east-2.console.aws.amazon.com/secretsmanager/newsecret?region=us-east-2")[aquí].

  Al momento de seleccionar el tipo de secreto, escoge "Other type of secret" y escribe:

  ```json
  {
    "username": "root",
    "password": "password123"
  }
  ```

  #align(center)[
    #figure(
      image("img/aws-sm-1.png", width: 80%),
    )
  ]

  #align(center)[
    #figure(
      image("img/aws-sm-2.png", width: 76%),
    )
  ]

  Asigna un nombre que te sirva para identificar a tu secreto. En este ejemplo, utilizaremos "db-creds".
]

#linear.slide(
  title: [Terraform],
  subtitle: [Flujo de trabajo],
)[
  Ahora que entendemos cómo manejar secretos y cómo interactúan AWS y Terraform, podemos comenzar a crear la infraestructura.

  #linear.callout[
    Recuerda que no es necesario copiar los comandos que vimos en las diapositivas anteriores ya que tendrás acceso a un repositorio con el proyecto Django + Terraform ya configurado.
  ]

  Inicializa el directorio y descarga los *providers* de AWS (solo la primera vez):
  ```bash
  terraform init
  ```

  Revisa los cambios que se aplicarán (sin ejecutarlos todavía):
  ```bash
  terraform plan
  ```

  #colbreak()
  Aplica los cambios y despliega la infraestructura:
  ```bash
  terraform apply
  ```

  #linear.callout(title: [Secreto de estado:])[
    El archivo `terraform.tfstate` guarda la relación entre tu código y los recursos reales. *Protégelo y no lo compartas.*
  ]
  #v(0.25em)
  Ahora puedes ir a cada componente dentro de la consola de AWS para verificar que los recursos se han creado correctamente. Algunos lugares que puedes revisar:
  #v(0.25em)
  - VPC: https://us-east-2.console.aws.amazon.com/vpcconsole/home?region=us-east-2#vpcs:
  - Subnets: https://us-east-2.console.aws.amazon.com/vpcconsole/home?region=us-east-2#subnets:
  - EC2: https://us-east-2.console.aws.amazon.com/ec2/home?region=us-east-2#Instances:instanceState=running
]

#linear.slide(
  title: [Terraform],
  subtitle: [Información útil después del deploy],
)[
  Después de `terraform apply`, es probable que querramos sabe ver la IP de nuestra app:

  ```hcl
  output "instance_ip" {
    description = "IP pública del servidor Django"
    value       = aws_instance.django.public_ip
  }

  output "app_url" {
    description = "URL de la aplicación"
    value       = "http://${aws_instance.django.public_ip}"
  }
  ```

  *Resultado en terminal:*

  ```
  Outputs:

  instance_ip = "99.999.99.999"
  app_url     = "http://99.999.99.999"    # Copia la URL, ábrela en tu navegador
  ```
]

#linear.focus-slide[
  Listo, ya tenemos acceso al servidor Django desplegado desde AWS 🎉
]

#linear.focus-slide[
  Mmmm... veo un error al acceder 🤔
]

#linear.image-slide[
  pendiente
]

#linear.slide(
  title: [Django],
  subtitle: [DisallowedHost],
)[
  Este error es causado por una medida de seguridad de Django. Ocurre porque, por defecto, Django solo permite peticiones desde localhost. Al acceder desde una IP pública, Django la rechaza.

  *La solución* consiste en indicar explícitamente qué dominios o IPs pueden acceder a nuestra aplicación.

  #set enum(spacing: 1em)
  1. Abre el archivo `proyecto1/settings.py`.
  2. Busca la línea ALLOWED_HOSTS.
  3. Añade la IP pública de tu instancia EC2 entre comillas. Si quieres permitir cualquier host (no recomendado para producción), puedes usar un asterisco.

    ```python
    ALLOWED_HOSTS = ["XX.XXX.XX.XXX", "*"] # Escribe la IP pública de tu instancia EC2 aquí
    ```

  #linear.callout()[
    *Importante*: Después de este cambio, necesitas reconstruir la imagen de Docker, subirla a ECR y volver a aplicar los cambios con `terraform apply` para que el servidor EC2 descargue la nueva versión de la imagen.
  ]
]

#linear.section-slide[Herramienta \#3: AWS RDS]

#linear.slide(
  title: [AWS RDS],
  subtitle: [De SQLite a PostgreSQL],
)[
  Hasta ahora, Django ha usado SQLite, una base de datos basada en un solo archivo. Funciona para desarrollo, pero *no es adecuada para producción*:

  - No soporta alta concurrencia (varios usuarios al mismo tiempo).
  - El archivo de la base de datos está dentro del contenedor, por lo que *se pierde si el contenedor se reinicia o reemplaza*.

  *La solución* es usar un servicio de base de datos gestionado como Amazon RDS. Sus ventajas:

  - Copias de seguridad, parches y posibilidad de escalar fácilmente.
  - Funciona de forma independiente del servidor de la aplicación (EC2).
  - Alta disponibilidad y durabilidad de los datos.

  #set enum(spacing: 0.75em)
  El plan consiste en:

  1. Crear `database.tf` para definir una instancia PostgreSQL en RDS.
  2. Actualizar `settings.py` para que Django se conecte a RDS.
  3. Pasar las credenciales de la base de datos de forma segura al contenedor Docker.
]

#linear.slide(
  title: [AWS RDS],
  subtitle: [Terraform (subnet)],
)[
  Primero, crearemos el archivo `database.tf` y definiremos los componentes de red para el RDS.

  RDS necesita un grupo de subnets que abarque al menos dos zonas de disponibilidad (_availability zones_) para alta disponibilidad.

  ```hcl
  resource "aws_db_subnet_group" "default" {
    name       = "django-db-subnet-group"
    subnet_ids = [
      aws_subnet.public.id,       // subnet #1
      aws_subnet.public_b.id,     // subnet #2
    ]
  }
  ```

  Luego, creamos un grupo de seguridad (_security group_) que solo permite conexiones entrantes en el puerto que usará PostgreSQL (5432):

  ```hcl
  resource "aws_security_group" "rds_sg" {
    name   = "django-rds-sg"
    vpc_id = aws_vpc.default.id

    ingress {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] // Para desarrollo: acceso desde cualquier IP
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ```

  #linear.callout()[
    En producción, reemplaza `0.0.0.0/0` por la IP del servidor EC2 para mayor seguridad.
  ]
]

#linear.slide(
  title: [AWS RDS],
  subtitle: [Terraform (instancia de la base de datos)],
)[
  Definimos nuestra instancia de PostgreSQL con Terraform usando `aws_db_instance`.

  ```hcl
    resource "aws_db_instance" "default" {
      engine               = "postgres"
      instance_class       = "db.t3.micro"
      db_name              = "django_db"
      username             = "admin"
      password             = var.db_password
      publicly_accessible  = true // Solo para migraciones desde local
    }
  ```

  Algunos detalles que valen la pena mencionar:

  - La instancia utilizará el *subnet group y security group* que creamos previamente.
  - `publicly_accessible = true` permite ejecutar migraciones desde tu ordenador; en producción debe ser `false`.
  - `db_password` debe manejarse como _secret_ (ver pág. 60).
]

#linear.slide(
  title: [AWS RDS],
  subtitle: [Conexión con Django],
)[
  Necesitamos actualizar `proyecto1/settings.py` para que lea la configuración de la base de datos desde variables de entorno. Esto evita escribir las credenciales en el código.

  ```python
  # ... otras configuraciones

  DATABASES = {
      "default": {
          "ENGINE": "django.db.backends.postgresql",
          "NAME": os.environ.get("DB_NAME"),
          "USER": os.environ.get("DB_USER"),
          "PASSWORD": os.environ.get("DB_PASSWORD"),
          "HOST": os.environ.get("DB_HOST"),
          "PORT": os.environ.get("DB_PORT"),
      }
  }
  ```
  Ahora, nuestro contenedor Django esperará que le pasemos estas 5 variables de entorno para poder conectarse a la base de datos.
]

#linear.slide(
  title: [AWS RDS],
  subtitle: [Actualizar script de inicio de la instancia EC2],
)[
  Modificamos el `user_data` en `main.tf` (revisar la pag. 53) para pasar las variables de entorno al contenedor Docker. Terraform permite obtener dinámicamente los valores de la instancia RDS recién creada.

  ```hcl
  user_data = <<-EOF
  # ... (instalación de Docker y login a ECR) ...

  docker run -d -p 80:8080 --restart unless-stopped \
    -e SECRET_KEY=${var.secret_key} \
    -e DB_NAME=${aws_db_instance.default.db_name} \
    -e DB_USER=${aws_db_instance.default.username} \
    -e DB_PASSWORD=${var.db_password} \
    -e DB_HOST=${aws_db_instance.default.address} \
    -e DB_PORT=${aws_db_instance.default.port} \
    YOUR_ECR_REGISTRY_URL/django-app:latest
  EOF
  ```

  `aws_db_instance.default.address` es el endpoint de la base de datos, obtenido automáticamente por Terraform una vez creada la instancia.
]

#linear.slide(
  title: [AWS RDS],
  subtitle: [Aplicar cambios y migrar],
)[
  Flujo de trabajo para desplegar la nueva configuración en AWS:

  1. *Reconstruir y subir la imagen Docker* con `settings.py` actualizado:

    ```bash
    docker build -t proyecto1-ec2 .
    docker tag ...
    docker push ...
    ```

  2. *Aplicar los cambios de Terraform*. Esto creará la instancia RDS y actualizará EC2 para usar la nueva imagen con las variables de entorno correctas:

    ```bash
    export TF_VAR_db_password="ContraseñaSegura123"
    terraform apply --auto-approve
    ```

    Este proceso puede tardar varios minutos mientras AWS provisiona la base de datos. Momento para darte un pequeño descanso o ir por un poco de aire fresco.

  #colbreak()

  3. *Ejecutar las migraciones de Django*. La base de datos RDS recién creada está vacía. Debemos conectarnos desde nuestra máquina local para crear las tablas iniciales.

    Primero, para obtener fácilmente la dirección de la base de datos, añade este output al archivo `database.tf`:

    ```hcl
    output "db_endpoint" {
      description = "Endpoint de la instancia de base de datos RDS"
      value       = aws_db_instance.default.endpoint
    }
    ```

    Ahora, después de `terraform apply`, verás el endpoint en la salida.

    Configura tu entorno local con *todas* las credenciales y ejecuta las migraciones:

    ```bash
    # En tu terminal local, con el entorno virtual activado
    export DB_HOST="<ENDPOINT_DE_RDS_AQUÍ>"     # Obtenido de la salida de Terraform
    export DB_NAME="django_db"                  # El que definiste en database.tf
    export DB_USER="admin"                      # El que definiste en database.tf
    export DB_PORT="5432"                       # Puerto por defecto de PostgreSQL
    export DB_PASSWORD="ContraseñaSegura123"    # La misma que usaste para 'terraform apply'
    ```

    Ahora sí, ejecuta los comandos de Django:
    ```bash
    python manage.py migrate
    python manage.py createsuperuser
    ```

    Ahora, si te diriges a http://XX.XXX.XX.XXX/admin/login/, deberías ver la página de inicio de sesión de Django. Inicia sesión con el usuario creado anteriormente y la contraseña que definiste.
]

#linear.image-slide[
  pendiente
]

#linear.focus-slide[
  Lo logramos, ahora podemos tanto acceder como iniciar sesión en nuestro sitio web usando Django 🎉
]

#linear.section-slide[Herramienta \#4: Amazon Cloudwatch]

#linear.slide(
  title: [Cloudwatch],
  subtitle: [¿Por qué centralizarlos?],
)[
  Por defecto, los logs de la aplicación (stdout y stderr) se guardan dentro del contenedor. Esto presenta varios problemas:

  - Si el contenedor se detiene o reemplaza, los logs se pierden.
  - Tendrías que conectarte manualmente por SSH y ejecutar `docker logs <id>`.
  - Repetir esto en varios servidores se vuelve impráctico.

  *La solución* es enviar los logs a un servicio centralizado, como *Amazon CloudWatch*.

  #figure(
    image("img/cloudwatch-diagram.png", width: 40%),
  )
]

#linear.slide(
  title: [Cloudwatch],
  subtitle: [Configurar Docker y permisos IAM],
)[
  Podemos configurar Docker para enviar logs directamente a CloudWatch usando el log driver `awslogs`.

  1. Actualizar la sección donde definimos "docker run" en el script `user_data` (este script se ejecuta al iniciar la instancia) dentro de `main.tf`:
    ```bash
    docker run -d -p 80:8080 --restart unless-stopped \
      --log-driver=awslogs \
      --log-opt awslogs-region=us-east-2 \
      --log-opt awslogs-group="django-app-logs" \
      --log-opt awslogs-create-group=true \
      // ... resto de variables -e ...
    ```

  #colbreak()

  2. Ahora, el servidor necesita permiso para escribir en CloudWatch. Creamos una política IAM y la adjuntamos al rol:
    ```hcl
    resource "aws_iam_policy" "cloudwatch_logs" {
      name   = "EC2CloudWatchLogsPolicy"
      policy = jsonencode({
        Version   = "2012-10-17",
        Statement = [{
          Effect   = "Allow",
          Action   = ["logs:CreateLogStream", "logs:PutLogEvents"],
          Resource = "arn:aws:logs:*:*:*"
        }]
      })
    }

    resource "aws_iam_role_policy_attachment" "ec2_logs" {
      role       = aws_iam_role.ec2_ecr.name
      policy_arn = aws_iam_policy.cloudwatch_logs.arn
    }
    ```
]

#linear.slide(
  title: [Cloudwatch],
  subtitle: [Visualizar en la consola de AWS],
)[
  Después de aplicar los cambios con `terraform apply`, todos los `print()` y logs de errores de Django aparecerán en CloudWatch. Para verlos:

  #set enum(spacing: 1em)
  1. Ve a la consola de AWS y busca *Cloudwatch*.
  2. En el menú izquierdo, selecciona *Logs > Log groups*.
  3. Haz clic en el grupo de logs creado: `django-app-logs`.

  #figure(
    image("img/cloudwatch-logs.jpg", width: 40%),
  )

  Ahora puedes buscar errores, filtrar por fecha y configurar alarmas, todo desde un único lugar.
]

#linear.focus-slide[
  Cloudwatch puede enviar alertas por SMS, email o incluso Slack/WhatsApp (requiere configuración extra) 🏄
]

#linear.slide(
  title: [Terraform],
  subtitle: [Destrucción de recursos],
)[
  Cuando finalices el proyecto, ejecuta:
  ```bash
    terraform destroy
  ```

  Terraform eliminará todos los recursos en orden inverso: primero la instancia EC2, luego los Security Groups, Route Tables, Subnets, el Internet Gateway y finalmente la VPC.

  Recuerda que *AWS cobra por recursos activos* (incluso si no los estés usando directamente). Si no los eliminas, podrías seguir generando costos. Por ejemplo, las instancias EC2 cuestan algo de \$0.01/hora (te saldría más o menos \$7/mes) o IP elástica (reservada y sin uso) unos \$0.005/hora.

  *Destruye siempre lo que no uses.*

  #linear.callout(title: [Tip])[
    Usa `terraform plan -destroy` para ver qué se eliminará antes de ejecutar la destrucción.
  ]
]

#linear.section-slide[Herramienta \#5: nginx]

#linear.slide(
  title: [nginx],
  subtitle: [Proxy inverso],
)[
  No es recomendable exponer Gunicorn directamente a internet. Gunicorn ejecuta la app Django, pero no está optimizado para tráfico HTTP, archivos estáticos o SSL. Para eso usamos un reverse proxy como nginx.

  #v(1em)

  #figure(
    image("img/diagram.png", width: 85%),
  )

  En la gráfica, la arquitectura consiste de:

  #v(1em)

  *nginx* (reverse proxy + servidor de archivos estáticos):

  - Recibe el tráfico público en los puertos 80 (HTTP).
  - Sirve archivos estáticos (carpeta `/static/`).
  - Reenvía las peticiones dinámicas a Gunicorn ( `proxy_pass`).

  #v(1em)

  *gunicorn* (servidor de aplicación WSGI):

  - Ejecuta la aplicación Django.
  - Espera peticiones en un puerto local no expuesto ( `127.0.0.1:8000`), accesible únicamente por nginx.
  - Gestiona procesos _worker_ de Python.

  #set enum(spacing: 0.9em)

  #colbreak()

  Para integrar nginx, debemos de:

  1. *Configurar `STATIC_ROOT`* en Django.

    Para usar exponer archivos estáticos con Django, Django necesita un directorio donde almacenar todos los archivos que nginx usará. En `proyecto1/settings.py`, define dónde `collectstatic` debe agrupar los archivos:

    ```python
    STATIC_URL = "static/"
    STATIC_ROOT = BASE_DIR / "staticfiles"
    ```

    Luego ejecuta:

    ```bash
    python manage.py collectstatic
    ```

    Esto generará la carpeta `staticfiles`.

  #colbreak()

  2. *Crear el archivo `nginx.conf`* con la configuración de proxy y archivos estáticos.

    Este archivo configurará Nginx para servir directamente los *archivos estáticos* generados por `collectstatic` (cuando el usuario accede a `/static/`) y redirigir el *resto de las solicitudes* a Gunicorn (por ejemplo, las páginas de tu aplicación Django).

    ```nginx
    server {
        listen 80;

        location /static/ {
            alias /app/staticfiles/;
        }

        # Redirigir todas las demás solicitudes a Gunicorn
        location / {
            proxy_pass http://127.0.0.1:8000;

            # Enviar encabezados importantes al servidor de aplicación
            proxy_set_header Host $host;
        }
    }
    ```

  #colbreak()

  3. Crear un script `entrypoint.sh` que *inicie ambos servicios*.

    Docker está diseñado para ejecutar un solo proceso principal por contenedor. La forma recomendada de producción es usar contenedores separados, uno para gunicorn y otro para nginx. *Como estamos en un entorno de desarrollo*, usaremos un único contenedor para ambos servicios.

    ```bash
    #!/bin/bash
    set -e

    python manage.py collectstatic --noinput --clear

    # Inicia nginx en primer plano
    nginx -g "daemon off;" &

    # Inicia Gunicorn como proceso principal
    exec gunicorn proyecto1.wsgi:application --bind 127.0.0.1:8000
    ```

    En el caso de Linux, no olvides dar los permisos de ejecución al script con:

    ```bash
    chmod +x entrypoint.sh
    ```

  #colbreak()

  4. *Actualizar el `Dockerfile`*. Añade los comandos para instalar Nginx y copiar los nuevos archivos.

    ```bash
    RUN apt-get install -y nginx

    # copiar los archivos
    COPY nginx.conf /etc/nginx/conf.d/default.conf
    COPY entrypoint.sh /app/entrypoint.sh

    # establecer al entrypoint.sh como punto de entrada
    ENTRYPOINT ["/app/entrypoint.sh"]
    ```

  5. *Modificar el mapeo de puertos en Terraform* para exponer solo los puertos públicos (80/443).

    En el `user_data` del recurso `aws_instance`, asegúrate de que el puerto mapeado sea `80:80`.

    ```bash
    # main.tf
    docker run -d -p 80:80 --restart unless-stopped \
           # ... (variables de entorno)
    ```

  #colbreak()

  Finalmente, reconstruye la imagen, súbela a ECR y aplica los cambios con Terraform.

  ```bash
  # 1. Construye la nueva imagen Docker
  docker build -t proyecto1-ec2 .

  # 2. Etiqueta la imagen para tu repositorio ECR
  # (Reemplaza YOUR_ECR_REPO_URL con la URL de tu repo)
  docker tag proyecto1-ec2:latest YOUR_ECR_REPO_URL:latest

  # 3. Sube la imagen a ECR
  docker push YOUR_ECR_REPO_URL:latest

  # 4. Aplica los cambios de infraestructura (si los hay)
  terraform apply --auto-approve
  ```
]

#linear.section-slide[En conclusión... 😮‍💨]

#linear.slide(
  title: [TLDR],
  subtitle: [¿Qué hicimos?],
)[
  En este workshop desplegaste:

  - Un proyecto Django en producción
  - Dockerizado y versionado en ECR
  - Corriendo en EC2 con infraestructura como código (Terraform)
  - Conectado a una base de datos PostgreSQL gestionada (RDS)
  - Conectado a Amazon Cloudwatch para monitoreo

  #linear.callout(title: [¡Felicidades!])[
    Todo usando el tier gratuito de AWS.
  ]
]

#linear.slide(
  title: [Recursos adicionales],
)[
  Documentación oficial:
  - Django: `docs.djangoproject.com`
  - Docker: `docs.docker.com`
  - Terraform: `registry.terraform.io/providers/hashicorp/aws`
  - AWS: `docs.aws.amazon.com`

  #v(2em)
  La mejor forma de aprender es construyendo.
]

#linear.qa-slide(
  question: [¡Gracias!],
  subtitle: [¿Preguntas? Siéntete libre de preguntar],
)
