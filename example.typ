#import "linear/lib.typ": focus-slide, outline-slide, slide, theme, title-slide
#import "linear/lib.typ": badge, callout, card, grid-layout, two-columns
#import "linear/lib.typ": colors

#show: theme.with(aspect-ratio: "16-9")

#title-slide(
  title: [Deploy en la nube... ☁️],
  subtitle: [AWS (EC2, Cloudwatch) + Django + Docker + nginx],
  author: [Cloud Engineering Workshop],
  date: datetime.today().display(),
)

#outline-slide(depth: 2)

#slide(
  title: [El resultado final],
  subtitle: [Lo que vamos a construir hoy],
)[
  Vamos a crear una aplicación Django en producción con:

  - Un proyecto Django corriendo en EC2
  - Dockerizado y versionado en ECR
  - Infraestructura gestionada con Terraform
  - Base de datos PostgreSQL en RDS
  - Dominio personalizado con HTTPS

  #v(1em)

  #callout(title: [Tip importante])[
    Todo esto lo haremos usando el tier gratuito de AWS.
  ]
]

#slide(title: [Por qué hacerlo bien])[
  #text(size: 24pt, weight: 600)[Manual vs automatizado]

  #v(1em)

  #two-columns(
    split: 50%,
    [
      *Forma manual:*
      - Click en la consola
      - Sin historial
      - No repetible
      - Difícil de revisar
    ],
    [
      *Con código:* #h(0.3em) #badge[Recomendado]
      - Versionado en git
      - Repetible
      - Revisable
      - Documentado
    ],
  )
]

#slide(title: [Componentes necesarios])[
  #grid-layout(
    columns: 2,
    gutter: 1em,

    card(
      title: [Docker],
      footer: [Paso 2],
    )[
      Empaqueta tu aplicación con todas sus dependencias en una imagen portable.
    ],

    card(
      title: [Amazon ECR],
      footer: [Paso 3],
    )[
      Registry para hospedar tus imágenes Docker en AWS.
    ],

    card(
      title: [Terraform],
      footer: [Paso 4],
    )[
      Infrastructure as Code para definir recursos de forma declarativa.
    ],

    card(
      title: [PostgreSQL RDS],
      footer: [Paso 5],
    )[
      Base de datos gestionada con backups automáticos y alta disponibilidad.
    ],
  )
]

#slide(title: [Crear el proyecto Django])[
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

#slide(title: [Dockerfile])[
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

  #callout(title: [Importante])[
    Usamos `slim-bullseye` para reducir el tamaño de la imagen y mejorar la seguridad.
  ]
]

#slide(title: [VPC y networking])[
  Una VPC (Virtual Private Cloud) es tu red privada en AWS.

  #two-columns(
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

      - VPC #badge[Red base]
      - Internet Gateway #badge[Acceso web]
      - Subnets #badge[Divisiones]
      - Security Groups #badge[Firewall]
    ],
  )
]

#focus-slide[
  Infrastructure as Code
]

#slide(title: [Aplicar cambios])[
  Una vez definida tu infraestructura en Terraform:

  ```bash
  terraform init
  terraform apply
  ```

  Terraform te muestra exactamente qué va a crear.

  #v(1em)

  #callout(title: [Listo])[
    Después de unos minutos, tu infraestructura estará desplegada.

    Ve a la consola de AWS → EC2 y verás tu servidor corriendo.
  ]
]

#slide(title: [Seguridad])[
  Algunas consideraciones importantes:

  #callout(title: [Nunca hagas esto])[
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

#slide(title: [Próximos pasos])[
  #grid-layout(
    columns: 3,
    gutter: 1em,

    card(title: [Optimizar])[
      Reduce el tamaño de la imagen Docker con `.dockerignore`
    ],

    card(title: [CI/CD])[
      Automatiza deploys con GitHub Actions
    ],

    card(title: [Monitoreo])[
      Implementa logs con CloudWatch
    ],
  )

  #v(1em)

  La mejor forma de aprender es construyendo. #badge[Empieza hoy]
]

#focus-slide[
  ¡Gracias!
]

#slide(footer: none)[
  #align(center + horizon)[
    #text(size: 40pt, weight: 600)[¿Preguntas?]

    #v(2em)

    #text(size: 18pt, fill: colors.muted)[
      Documentación y recursos disponibles en el repositorio
    ]
  ]
]
