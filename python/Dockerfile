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
