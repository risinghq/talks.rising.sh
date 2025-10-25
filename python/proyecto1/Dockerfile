FROM python:3.12.0-slim

RUN apt-get update && apt-get install -y nginx && apt-get clean

ENV PORT=80
WORKDIR /app

COPY ./requirements.txt /app/
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

COPY ./proyecto1 /app/proyecto1
COPY ./manage.py /app/
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY ./entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh

EXPOSE ${PORT}

ENTRYPOINT ["/app/entrypoint.sh"]
