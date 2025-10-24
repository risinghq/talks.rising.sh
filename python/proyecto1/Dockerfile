# Usamos una imagen base ligera de Python.
FROM python:3.12.0-slim

# Instalamos nginx dentro de la misma imagen para actuar como reverse proxy.
# apt-get clean reduce el tamaño final de la imagen.
RUN apt-get update && apt-get install -y nginx && apt-get clean

# Definimos variables de entorno para configuración.
ENV PORT=80
WORKDIR /app

# Copiamos e instalamos las dependencias de Python.
# Separar este paso permite a Docker usar la caché si solo cambia el código.
COPY ./requirements.txt /app/
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copiamos el código de la aplicación Django y los scripts.
COPY ./proyecto1 /app/proyecto1
COPY ./manage.py /app/
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY ./entrypoint.sh /app/entrypoint.sh

# Damos permisos de ejecución al script de inicio.
RUN chmod +x /app/entrypoint.sh

# Documentamos el puerto que la aplicación expondrá.
EXPOSE ${PORT}

# El ENTRYPOINT es el comando que se ejecuta al iniciar el contenedor.
# Nuestro script se encargará de iniciar tanto Nginx como Gunicorn.
ENTRYPOINT ["/app/entrypoint.sh"]
