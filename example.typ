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

#linear.section-slide[Herramienta \#2: Terraform]

#linear.slide(
  title: [Terraform],
  subtitle: [¿Por qué lo vamos a usar?],
)[
  Imagina que configuraste tu aplicación Django manualmente en AWS:

  - Hiciste clic en 47 botones diferentes en la consola
  - Configuraste redes, subnets, security groups...
  - Todo funcionó perfectamente ✓

  *Pero ahora necesitas:*
  - Replicarlo en producción (a escala, es decir, en múltiples regiones, cuentas e instancias)
  - Que tu compañero configure su entorno
  - Documentar qué hiciste exactamente

  #linear.callout(title: [La realidad])[
    Probablemente olvidaste qué hiciste en el paso 23. Y tu compañero va a configurar algo diferente.
  ]
]

#linear.slide(
  title: [Terraform],
  subtitle: [La solución],
)[
  Terraform te permite escribir tu infraestructura como código:

  ```hcl
  resource "aws_instance" "web" {
    ami           = "ami-0c101f26f147fa7fd"
    instance_type = "t3.micro"
  }
  ```

  *Ventajas:*
  - El mismo código = la misma infraestructura (siempre). Sin importar el proveedor (AWS, Google Cloud)
  - Versionado con Git (sabes qué cambió y cuándo, útil en caso de bugs)
  - Replicable en segundos (no en 47 clics)
  - Auto-documentado (el código ES la documentación)

  #linear.callout(title: [Instalación])[
    Descarga desde: #link("https://developer.hashicorp.com/terraform/install-cli")[developer.hashicorp.com/terraform/install-cli]
  ]
]

#linear.slide(
  title: [Terraform],
  subtitle: [Flujo de trabajo],
)[
  // #image("flow-diagram.png", width: 100%)

  *Nuestro objetivo final:*
  1. Hacer que Django pase de correr localmente a estar dentro de un contenedor Docker.
  2. Crear la imagen Docker y subirla a AWS ECR.
  3. Usar Terraform para levantar un servidor EC2 que descargue y ejecute tu imagen.
  4. Resultado: tu aplicación estará disponible desde una IP pública.

  #v(1em)

  #linear.callout(title: [Lo que automatizaremos])[
    Todo el paso 3: red, permisos, servidor y deployment automático
  ]
]

#linear.slide(
  title: [Terraform],
  subtitle: [Componentes de AWS],
)[
  Para desplegar Django en AWS necesitamos "construir el edificio". Explicar a fondo cómo funciona Terraform está fuera del alcance de este workshop, pero para darte una idea, podemos usar estas analogías:

  #linear.two-columns(
    split: 50%,
    [
      *VPC (Virtual Private Cloud)*

      Tu terreno delimitado en AWS. Todo vive aquí dentro.

      #v(1em)

      *Subnets*

      Divisiones dentro del terreno para organizar recursos.

      #v(1em)

      *Internet Gateway*

      La puerta de entrada que conecta tu edificio con internet.
    ],
    [
      *Route Tables*

      Señalética que indica cómo mover el tráfico.

      #v(1em)

      *Security Groups*

      Guardias de seguridad: quién puede entrar y por dónde.

      #v(1em)

      *EC2 Instance*

      El servidor donde corre tu aplicación Django.
    ],
  )

  #v(1em)

  Terraform creará todo esto automáticamente siguiendo el orden correcto.
]

#linear.slide(
  title: [Terraform],
  subtitle: [VPC y el internet gateway],
)[
  #linear.two-columns(
    split: 50%,
    [
      Primero, le decimos a Terraform que usaremos AWS:

      ```hcl
      provider "aws" {
        region = "us-east-1"
      }
      ```

      #v(1em)

      Luego creamos nuestra red privada (VPC):

      ```hcl
      resource "aws_vpc" "default" {
        cidr_block = "10.0.0.0/16"
        enable_dns_hostnames = true
        tags = { Name = "Django_VPC" }
      }
      ```

      *¿Qué significa?*

      Tenemos 65,536 IPs disponibles para nuestros recursos.
    ],
    [
      Y conectamos con internet:

      ```hcl
      resource "aws_internet_gateway" "default" {
        vpc_id = aws_vpc.default.id
        tags = { Name = "Django_IGW" }
      }
      ```

      #v(1em)

      *Un detalle:* `aws_vpc.default.id`

      Terraform entiende las dependencias. No puedes crear el gateway sin VPC primero.

      #v(1em)

      #linear.callout(title: [DNS habilitado])[
        `enable_dns_hostnames = true` permite usar nombres como `mi-db.internal` en vez de IPs
      ]
    ],
  )
]

#linear.slide(
  title: [Terraform],
  subtitle: [Subnets y enrutamiento],
)[
  Creamos una subnet pública (accesible desde internet):
  ```hcl
  resource "aws_subnet" "public" {
    vpc_id                  = aws_vpc.default.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-east-2"
    map_public_ip_on_launch = true  # Cada instancia recibe IP pública automáticamente
    tags = { Name = "Django_Public_Subnet" }
  }
  ```

  Y configuramos la ruta de salida a internet:
  ```hcl
  resource "aws_route_table" "public" {
    vpc_id = aws_vpc.default.id
    route {
      cidr_block = "0.0.0.0/0"  # Cualquier IP externa
      gateway_id = aws_internet_gateway.default.id  # Va por el gateway
    }
  }
  ```

  Traducción: "Si el destino NO está en mi VPC (10.0.0.0/16), envíalo a internet"
]

#linear.slide(
  title: [Terraform],
  subtitle: [Security groups: ingress],
)[
  ```hcl
  resource "aws_security_group" "django" {
    name   = "django_sg"
    vpc_id = aws_vpc.default.id

    # Permitir tráfico HTTP desde cualquier lugar
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    # Permitir SSH solo para administración (opcional)
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]  # En producción: tu IP específica
    }
  }
  ```
]

#linear.slide(
  title: [Terraform],
  subtitle: [Security groups: egress],
)[
  ```hcl
  resource "aws_security_group" "ec2_sg" {
    name   = "django_ec2_sg"
    vpc_id = aws_vpc.default.id

    # Permite tráfico de salida para descarga de paquetes u otros recursos necesarios
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
  subtitle: [Roles IAM para EC2],
)[
  El servidor necesita permisos IAM para descargar la imagen Docker desde ECR. Este recurso crea un rol IAM (`aws_iam_role`) que EC2 puede asumir, otorgándole permisos temporales según sea necesario.

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
  subtitle: [Políticas y perfil de EC2],
)[
  Se adjunta la política de solo lectura a ECR y se crea un perfil de instancia para EC2.

  *Qué hace cada recurso:*

  - `aws_iam_role_policy_attachment`: da permisos de solo lectura a ECR.
  - `aws_iam_instance_profile`: permite que la EC2 use el rol creado.

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
]

#linear.slide(
  title: [Terraform],
  subtitle: [Servidor EC2],
)[
  ```hcl
  resource "aws_instance" "django" {
    ami                    = "ami-0c101f26f147fa7fd"  # Amazon Linux 2023
    instance_type          = "t3.micro"                # Free tier (1GB RAM, 2 vCPUs)
    subnet_id              = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.django.id]
    iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

    user_data = <<-EOF
      # Aquí va el script que se ejecuta al iniciar la instancia
    EOF

    tags = { Name = "Django_Server" }
  }
  ```
]

#linear.slide(
  title: [Terraform],
  subtitle: [User Data script],
)[
  Este script se ejecuta UNA VEZ cuando la instancia inicia:

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

  #linear.callout(title: [Mapeo de puertos])[
    `-p 80:8080` expone puerto 8080 del contenedor en el puerto 80 del host
  ]
]

#linear.slide(
  title: [Terraform],
  subtitle: [Variables de entorno],
)[
  Nunca pongas secretos en el código:

  #linear.two-columns(
    split: 50%,
    [
      *variables.tf*

      ```hcl
      variable "secret_key" {
        description = "Django SECRET_KEY"
        type        = string
        sensitive   = true  # Oculto en logs
      }

      variable "ecr_registry" {
        description = "ECR Registry URL"
        type        = string
      }
      ```
    ],
    [
      *terraform.tfvars* (no commitear)

      ```hcl
      secret_key   = "tu-clave-super-secreta-aquí"
      ecr_registry = "123456.dkr.ecr.us-east-1.amazonaws.com"
      ```
      #v(1em)
      *`.gitignore`*

      ```
      terraform.tfvars
      *.tfstate
      *.tfstate.backup
      ```
    ],
  )

  Uso: `${var.secret_key}` en cualquier parte del código.
]

#linear.slide(
  title: [Terraform],
  subtitle: [Flujo de trabajo],
)[
  Prepara el directorio y descarga los providers de AWS (solo la primera vez):
  ```bash
  terraform init
  ```

  Para ver qué cambios se harán (sin aplicar), ejecuta:
  ```bash
  terraform plan
  ```

  Para aplicar los cambios, ejecuta:
  ```bash
  terraform apply
  ```

  #linear.callout(title: [Estado])[
    `terraform.tfstate` guarda el mapeo entre tu código y recursos reales. ¡Protégelo!
  ]
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

  instance_ip = "18.220.45.123"
  app_url     = "http://18.220.45.123"    # Copia la URL, ábrela en tu navegador
  ```
]

#linear.slide(
  title: [Terraform],
  subtitle: [Cómo modificar la infraestructura],
)[
  *Escenario:* Quieres abrir el puerto 8000 para debugging. Edita `main.tf`:

  ```hcl
  ingress {
    description = "Django dev server"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ```

  Ejecuta:

  ```bash
  terraform plan   # Verás: "aws_security_group.django will be updated"
  terraform apply  # Solo modifica el security group
  ```

  #linear.callout()[
    Terraform NO recrea todo. Solo actualiza lo que cambió gracias al archivo de estado.
  ]
]

#linear.slide(
  title: [Terraform],
  subtitle: [Destrucción de recursos],
)[
  Cuando termines con el proyecto, es recomendable ejecutar:
  ```bash
  terraform destroy
  ```

  Terraform eliminará TODO en orden inverso: Primero la instancia EC2, luego Security Groups, Route Tables y asociaciones, Subnets, Internet Gateway, VPC.

  #linear.callout(title: [Sobre los costos])[
    AWS cobra por recursos activos. Si no destruyes:
    - Instancia EC2: ~\$0.01/hora = ~\$7/mes
    - IP elástica (si la reservas): \$0.005/hora cuando no está en uso

    *Destruye lo que no uses.*
  ]

  Tip: `terraform plan -destroy` muestra qué se eliminará sin hacerlo.
]

#linear.section-slide[Dominio y HTTPS]

#linear.slide(
  title: [Dominio],
  subtitle: [Por qué un Application Load Balancer],
)[
  Podrías apuntar tu dominio directamente a la IP de EC2, pero un Load Balancer (ALB) es la forma profesional de hacerlo:
  - *HTTPS:* Gestiona certificados SSL gratis con AWS Certificate Manager (ACM).
  - *Escalabilidad:* Puede distribuir tráfico entre múltiples servidores.
  - *Alta disponibilidad:* Si un servidor falla, puede redirigir el tráfico a otros.

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
  - Con dominio personalizado y HTTPS

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
  question: [¡Gracias!... ¿Preguntas?],
  subtitle: [Siéntete libre de preguntar],
)
