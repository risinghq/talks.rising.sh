#import "linear/lib.typ": linear

#show: linear.theme.with(
  aspect-ratio: "16-9",
  config-info: (
    title: "Desplegando Django en AWS",
    subtitle: "El camino correcto",
    author: "Cloud Engineering Workshop",
    date: datetime.today(),
  ),
)

// Title slide
#linear.title-slide(
  title: [Desplegando Django en AWS],
  subtitle: [El camino correcto: Docker, Terraform y PostgreSQL],
  author: [Cloud Engineering Workshop],
  date: [Octubre 2025],
)

// Table of contents
#linear.outline-slide(depth: 2)

// Regular slide
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

  #v(1em)
  
  #linear.callout(
    type: "info",
    title: [Tip importante],
  )[
    Todo esto lo haremos usando el tier gratuito de AWS.
  ]
]

// Slide with two columns
#linear.slide(title: [Por qué hacerlo bien])[
  #linear.two-columns(
    split: 45%,
    [
      = Manual vs automatizado
      
      *Forma manual:*
      - Click en la consola
      - Sin historial
      - No repetible
      - Difícil de revisar
    ],
    [
      #v(1em)
      *Con código:*
      - Versionado en git
      - Repetible
      - Revisable
      - Documentado
      
      #v(1em)
      #linear.badge(type: "success")[Recomendado]
    ]
  )
]

// Slide with cards
#linear.slide(title: [Componentes necesarios])[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1em,
    
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

// Slide with code
#linear.slide(title: [Crear el proyecto Django])[
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

// Slide with inline code and callouts
#linear.slide(title: [Dockerfile])[
  Creamos un `Dockerfile` para empaquetar nuestra aplicación:

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

  #v(0.5em)

  #linear.callout(type: "warning", title: [Importante])[
    Usamos `slim-bullseye` para reducir el tamaño de la imagen y mejorar la seguridad.
  ]
]

// Slide with mixed content
#linear.slide(title: [VPC y networking])[
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
    ]
  )
]

// Focus slide
#linear.focus-slide[
  Infrastructure as Code
]

// Slide with success message
#linear.slide(title: [Aplicar cambios])[
  Una vez definida tu infraestructura en Terraform:

  ```bash
  terraform init
  terraform apply
  ```

  Terraform te muestra exactamente qué va a crear.

  #v(1em)

  #linear.callout(type: "success", title: [Listo])[
    Después de unos minutos, tu infraestructura estará desplegada. 
    
    Ve a la consola de AWS → EC2 y verás tu servidor corriendo.
  ]
]

// Slide with danger callout
#linear.slide(title: [Seguridad])[
  Algunas consideraciones importantes:

  #linear.callout(type: "danger", title: [Nunca hagas esto])[
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

// Final slide with cards
#linear.slide(title: [Próximos pasos])[
  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 1em,
    
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
  
  La mejor forma de aprender es construyendo. #linear.badge(type: "accent")[Empieza hoy]
]

// Thank you slide
#linear.focus-slide[
  ¡Gracias!
]

// Q&A slide
#linear.slide(footer: none)[
  #align(center + horizon)[
    #text(size: 48pt, weight: 600)[¿Preguntas?]
    
    #v(2em)
    
    #text(size: 20pt, fill: linear.colors.muted-fg)[
      Documentación y recursos disponibles en el repositorio
    ]
  ]
]
