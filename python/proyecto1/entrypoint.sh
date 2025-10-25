#!/bin/sh
# Entrypoint script for Django + Gunicorn + Nginx
# This script handles database setup, static files, and starts the application

set -e

export DJANGO_SETTINGS_MODULE=proyecto1.settings

# Ensure static files directory exists
mkdir -p /app/staticfiles

# Wait for database to be ready with retry logic
echo "Waiting for database to be ready..."

for attempt in $(seq 1 30); do
    if python manage.py migrate --noinput 2>/dev/null; then
        echo "Database is ready and migrations completed successfully!"
        break
    else
        if [ "$attempt" = "30" ]; then
            echo "Database failed to become ready after 30 attempts"
            exit 1
        fi
        echo "  Attempt $attempt/30: Database not ready yet, retrying in 2 seconds..."
        sleep 2
    fi
done

# Collect static files
echo ""
echo "Collecting static files..."
python manage.py collectstatic --noinput --clear
echo "Static files collected"

# Start Nginx in background
nginx
echo "Nginx started on port 80"

# Start Gunicorn as the main process
echo ""
echo "Gunicorn listening on 0.0.0.0:8000"
echo "Application is running!"
echo ""

exec gunicorn proyecto1.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 2 \
    --timeout 60 \
    --access-logfile - \
    --error-logfile -
