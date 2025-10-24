#!/bin/sh

# 'set -e' asegura que el script se detenga si algún comando falla.
set -e

# Ejecutamos collectstatic para que Django agrupe todos los archivos estáticos
# en el directorio STATIC_ROOT que Nginx puede servir.
echo "Recolectando archivos estáticos..."
python manage.py collectstatic --noinput --clear

# Iniciamos Nginx en segundo plano.
echo "Iniciando Nginx..."
nginx

# Iniciamos Gunicorn como el proceso principal del contenedor.
# 'exec' reemplaza el proceso del shell con Gunicorn, lo que es una buena práctica
# para la gestión de señales (ej. al parar el contenedor).
echo "Iniciando Gunicorn..."
exec gunicorn proyecto1.wsgi:application --bind 127.0.0.1:8000
