#!/usr/bin/env bash


# make our folders
mkdir -p \
    /config/www/{avatars,backgrounds,icons,logs,SupportedApps} \
    /config/log/heimdall

# writable laravel scratch dirs
mkdir -p \
    /tmp/heimdall/bootstrap-cache \
    /tmp/heimdall/framework/{cache/data,sessions,testing,views}

# copy searchproviders if not exists and symlink
if [[ ! -f /config/www/searchproviders.yaml ]]; then
    cp /app/www/storage/app/searchproviders.yaml.orig /config/www/searchproviders.yaml
fi

# copy .env if not exists
if [[ ! -f /config/www/.env ]]; then
    install -g apps -o apps /app/www/.env.example /config/www/.env
    echo "Creating app key. This may take a while on slower systems"
     php /app/www/artisan key:generate
fi

# set queue driver to database
sed -i 's/QUEUE_DRIVER=sync/QUEUE_DRIVER=database/' /config/www/.env

exec php -S 0.0.0.0:80 -t /app/www/public
