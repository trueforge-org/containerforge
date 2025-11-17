#!/usr/bin/env bash




mkdir -p /config/{data,media}
rm -rf /app/www/public/{data,media}
ln -s /config/data /app/www/public/data
ln -s /config/media /app/www/public/media

cd /app/www/public || exit 1

if [[ ! -f "/config/.secretkey" ]]; then
    echo "**** No secret key found, generating one ****"
    python3 manage.py shell -c 'from django.core.management import utils; print(utils.get_random_secret_key())' |
        tr -d '\n' >/config/.secretkey
fi

export \
    DJANGO_SETTINGS_MODULE="babybuddy.settings.base" \
    ALLOWED_HOSTS="${ALLOWED_HOSTS:-*}" \
    TIME_ZONE="${TZ:-UTC}" \
    DEBUG="${DEBUG:-False}" \
    SECRET_KEY="${SECRET_KEY:-$(cat /config/.secretkey)}"
python3 manage.py migrate --noinput
python3 manage.py createcachetable

# permissions

    /config





export \
    DJANGO_SETTINGS_MODULE="babybuddy.settings.base" \
    ALLOWED_HOSTS="${ALLOWED_HOSTS:-*}" \
    TIME_ZONE="${TZ:-UTC}" \
    DEBUG="${DEBUG:-False}" \
    SECRET_KEY="${SECRET_KEY:-$(cat /config/.secretkey)}"

exec \
    
    cd /app/www/public  gunicorn babybuddy.wsgi -b 127.0.0.1:3000 --log-level=info \
    --worker-tmp-dir=/dev/shm --log-file=- \
    --workers=2 --threads=4 --worker-class=gthread

