#!/bin/sh

# O shell irá encerrar a execução do script quando um comando falhar
set -e

python manage.py collectstatic --noinput
python manage.py makemigrations --noinput
python manage.py migrate --noinput

exec gunicorn config.wsgi:application --bind 0.0.0.0:8000 --workers 3 --reload