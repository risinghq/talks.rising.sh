#import "linear/lib.typ" as linear

#show: linear.theme.with(aspect-ratio: "16-9")

#linear.title-slide(
  title: [Deploy en la nube... ☁️],
  subtitle: [AWS (EC2, Cloudwatch) + Django + Docker + nginx],
)

#linear.outline-slide()

#linear.slide(
  title: [El resultado final],
  subtitle: [Lo que vamos a construir hoy],
)[
  Vamos a crear una aplicación Django en producción con:

  - Un proyecto Django corriendo en EC2
  - Dockerizado y versionado en ECR
  - Infraestructura gestionada con Terraform
  - Base de datos PostgreSQL en RDS
  - Dominio personalizado con HTTPS

  #linear.callout(title: [Tip importante])[
    Todo esto lo haremos usando el tier gratuito de AWS.
  ]
]

#linear.slide(title: [Por qué hacerlo bien])[
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

#linear.slide(title: [Componentes necesarios])[
  #linear.grid-layout(
    columns: 2,
    linear.card(title: [Docker], footer: [Paso 2])[
      Empaqueta tu aplicación con todas sus dependencias en una imagen portable.
    ],

    linear.card(title: [Amazon ECR], footer: [Paso 3])[
      Registry para hospedar tus imágenes Docker en AWS.
    ],

    linear.card(title: [Terraform], footer: [Paso 4])[
      Infrastructure as Code para definir recursos de forma declarativa.
    ],

    linear.card(title: [PostgreSQL RDS], footer: [Paso 5])[
      Base de datos gestionada con backups automáticos y alta disponibilidad.
    ],
  )
]

#linear.slide(title: [API Request Fields])[
  Estructura de datos para las solicitudes en Linear:

  #linear.data-table(
    headers: ([Field], [Type], [Description]),
    rows: (
      (
        [`customerId`],
        [`uuid`],
        [The `id` of the Customer in Linear this request is associated with. Can be `undefined` if the request is not attached to a Customer.],
      ),
      (
        [`issueId`],
        [`uuid`],
        [The `id` of the Issue this request is associated with.],
      ),
      (
        [`attachmentId`],
        [`uuid`],
        [The `id` of the Attachment this request is associated with. All requests with a source URL are backed by an Attachment.],
      ),
      (
        [`priority`],
        [`number`],
        [Whether the customer request is important or not. `0` = Not important, `1` = Important.],
      ),
      (
        [`body`],
        [`string`],
        [Optional content for the request, in markdown format.],
      ),
      (
        [`creatorId`],
        [`uuid`],
        [The `id` of the User in Linear who created the request.],
      ),
    ),
  )
]

#linear.slide(title: [Crear el proyecto Django])[
  Primero, instalamos Django y creamos el proyecto:

  #block(width: 75%)[
    ```bash
    python3.12 -m venv venv
    source venv/bin/activate
    pip install django gunicorn psycopg2-binary
    pip freeze > requirements.txt
    ```
  ]
]

#linear.slide(title: [Dockerfile])[
  Creamos un `Dockerfile` para empaquetar nuestra aplicación:

  #block(width: 75%)[
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
  ]

  #linear.callout(title: [Importante])[
    Usamos `slim-bullseye` para reducir el tamaño de la imagen y mejorar la seguridad.
  ]
]

#linear.slide(title: [VPC y networking])[
  Una VPC (Virtual Private Cloud) es tu red privada en AWS.

  #linear.two-columns(
    split: 55%,
    [
      #block(width: 100%)[
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
      ]
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

#linear.slide(title: [Aplicar cambios])[
  Una vez definida tu infraestructura en Terraform:

  #block(width: 75%)[
    ```bash
    terraform init
    terraform apply
    ```
  ]

  #linear.callout(title: [Listo])[
    Después de unos minutos, tu infraestructura estará desplegada. Ve a la consola de AWS → EC2 y verás tu servidor corriendo.
  ]
]

#linear.slide(title: [Seguridad])[
  Algunas consideraciones importantes:

  #linear.callout(title: [Nunca hagas esto], type: "danger")[
    - No pongas credenciales en el código
    - No uses `DEBUG = True` en producción
    - No expongas todos los puertos al internet
  ]

  *Usa variables de entorno* para configuración sensible:

  #block(width: 75%)[
    ```python
    SECRET_KEY = os.getenv('SECRET_KEY')
    DB_PASSWORD = os.getenv('DB_PASSWORD')
    ```
  ]
]

#linear.slide(title: [Próximos pasos])[
  #linear.grid-layout(
    columns: 3,
    gutter: 1.5em,
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

  #v(1.5em)

  La mejor forma de aprender es construyendo. #linear.badge(type: "accent")[Empieza hoy]
]

#linear.focus-slide[
  ¡Gracias!
]

#linear.qa-slide(
  question: [¿Preguntas?],
  subtitle: [Documentación y recursos disponibles en el repositorio],
)
