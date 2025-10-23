#import "@local/linear:0.1.0"

#show: linear.theme.with(aspect-ratio: "16-9")

#linear.title-slide(
  title: [Deploy en la nube... ☁️],
  subtitle: [AWS (EC2, Cloudwatch) + Django + Docker + nginx],
  author: [Cloud Engineering Workshop],
  date: datetime.today().display(),
)

#linear.outline-slide(depth: 2)

= El resultado final

#linear.slide(
  subtitle: [Lo que vamos a construir hoy],
)[
  Vamos a crear una aplicación Django en producción con:

  - Un proyecto Django corriendo en EC2
  - Dockerizado y versionado en ECR
  - Infraestructura gestionada con Terraform
  - Base de datos PostgreSQL en RDS
  - Dominio personalizado con HTTPS

  #v(1em)

  #linear.callout(title: [Tip importante])[
    Todo esto lo haremos usando el tier gratuito de AWS.
  ]
]

= Por qué hacerlo bien

#linear.slide[
  #text(size: 24pt, weight: 600)[Manual vs automatizado]

  #v(1em)

  #linear.two-columns(
    split: 50%,
    [
      *Forma manual:*
      - Click en la consola
      - Sin historial
      - No repetible
      - Difícil de revisar
    ],
    [
      *Con código:* #h(0.3em) #linear.badge[Recomendado]
      - Versionado en git
      - Repetible
      - Revisable
      - Documentado
    ],
  )
]

= Componentes necesarios

#linear.slide[
  #linear.grid-layout(
    columns: 2,
    gutter: 1em,

    linear.card(
      title: [Docker],
      footer: [Paso 2],
    )[
      Empaqueta tu aplicación con todas sus dependencias en una imagen portable.
    ],

    linear.card(
      title: [Amazon ECR],
      footer: [Paso 3],
    )[
      Registry para hospedar tus imágenes Docker en AWS.
    ],

    linear.card(
      title: [Terraform],
      footer: [Paso 4],
    )[
      Infrastructure as Code para definir recursos de forma declarativa.
    ],

    linear.card(
      title: [PostgreSQL RDS],
      footer: [Paso 5],
    )[
      Base de datos gestionada con backups automáticos y alta disponibilidad.
    ],
  )
]

= Crear el proyecto Django

#linear.slide[
  Primero, instalamos Django y creamos el proyecto:

  ```bash
  python3.12 -m pip install django
  python3.12 -m django startproject django_ec2_complete
  cd django_ec2_complete
  ```

  Configuramos un entorno virtual:

  ```bash
  python3.12 -m venv venv
  source venv/bin/activate
  pip install django gunicorn psycopg2-binary
  pip freeze > requirements.txt
  ```
]

= Dockerfile

#linear.slide[
  Creamos un `Dockerfile` para empaquetar nuestra aplicación:

  ```dockerfile
  FROM python:3.12.2-slim-bullseye
  ENV PYTHONBUFFERED=1
  ENV PORT 8080
  WORKDIR /app
  COPY . /app/
  RUN pip install --upgrade pip
  RUN pip install -r requirements.txt
  CMD gunicorn django_ec2_complete.wsgi:application --bind 0.0.0.0:"${PORT}"
  EXPOSE ${PORT}
  ```

  #v(0.5em)

  #linear.callout(title: [Importante])[
    Usamos `slim-bullseye` para reducir el tamaño de la imagen y mejorar la seguridad.
  ]
]

= VPC y networking

#linear.slide[
  Una VPC (Virtual Private Cloud) es tu red privada en AWS.

  #linear.two-columns(
    split: 60%,
    [
      ```hcl
      resource "aws_vpc" "default" {
        cidr_block           = "10.0.0.0/16"
        enable_dns_support   = true
        enable_dns_hostnames = true
        tags = {
          Name = "Django_EC2_VPC"
        }
      }
      ```
    ],
    [
      *Componentes clave:*

      - VPC #linear.badge[Red base]
      - Internet Gateway #linear.badge[Acceso web]
      - Subnets #linear.badge[Divisiones]
      - Security Groups #linear.badge[Firewall]
    ],
  )
]

#linear.focus-slide[
  Infrastructure as Code
]

= Aplicar cambios

#linear.slide[
  Una vez definida tu infraestructura en Terraform:

  ```bash
  terraform init
  terraform apply
  ```

  Terraform te muestra exactamente qué va a crear.

  #v(1em)

  #linear.callout(title: [Listo])[
    Después de unos minutos, tu infraestructura estará desplegada.

    Ve a la consola de AWS → EC2 y verás tu servidor corriendo.
  ]
]

= Seguridad

#linear.slide[
  Algunas consideraciones importantes:

  #linear.callout(title: [Nunca hagas esto])[
    - No pongas credenciales en el código
    - No uses `DEBUG = True` en producción
    - No expongas todos los puertos al internet
  ]

  #v(1em)

  *Usa variables de entorno* para configuración sensible:

  ```python
  SECRET_KEY = os.getenv('SECRET_KEY')
  DB_PASSWORD = os.getenv('DB_PASSWORD')
  ```
]

= Próximos pasos

#linear.slide[
  #linear.grid-layout(
    columns: 3,
    gutter: 1em,

    linear.card(title: [Optimizar])[
      Reduce el tamaño de la imagen Docker con `.dockerignore`
    ],

    linear.card(title: [CI/CD])[
      Automatiza deploys con GitHub Actions
    ],

    linear.card(title: [Monitoreo])[
      Implementa logs con CloudWatch
    ],
  )

  #v(1em)

  La mejor forma de aprender es construyendo. #linear.badge[Empieza hoy]
]

#linear.focus-slide[
  ¡Gracias!
]

= ¿Preguntas?

#linear.slide(footer: none)[
  #align(center + horizon)[
    #text(size: 40pt, weight: 600)[¿Preguntas?]

    #v(2em)

    #text(size: 18pt, fill: linear.colors.muted)[
      Documentación y recursos disponibles en el repositorio
    ]
  ]
]
