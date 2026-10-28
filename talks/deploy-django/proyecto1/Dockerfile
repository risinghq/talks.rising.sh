FROM python:3.14-slim
COPY --from=ghcr.io/astral-sh/uv:0.13.6 /uv /bin/

RUN apt-get update && apt-get install -y --no-install-recommends nginx && rm -rf /var/lib/apt/lists/*

ENV PORT=80
ENV PATH="/app/.venv/bin:$PATH"
WORKDIR /app

COPY pyproject.toml uv.lock /app/
RUN uv sync --locked --no-dev

COPY ./proyecto1 /app/proyecto1
COPY ./manage.py /app/
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY ./entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh && \
    mkdir -p /app/staticfiles

EXPOSE ${PORT}

ENTRYPOINT ["/app/entrypoint.sh"]
