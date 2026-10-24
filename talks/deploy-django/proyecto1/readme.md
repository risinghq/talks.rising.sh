# proyecto1

The Django project as it stands at the end of the talk. It starts from:

```bash
uv init --bare
uv add django gunicorn psycopg2-binary
uv run django-admin startproject proyecto1 .
```

The talk then makes `proyecto1/settings.py` read its secrets and database from
the environment, and adds the Dockerfile, `entrypoint.sh`, `nginx.conf` and the
Terraform files.
