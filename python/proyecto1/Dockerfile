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
