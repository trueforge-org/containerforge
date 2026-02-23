#!/usr/bin/env bash





if [[ -z "${DATABASE_URL:-}" ]]; then
    export DATABASE_URL="sqlite:////config/kimai.sqlite"
fi

mkdir -p /config/www/var/{cache,data,log,packages,plugins,sessions}
cp /app/www/config/packages/kimai.yaml /config/kimai.yaml.sample
if [[ ! -f /config/local.yaml ]]; then
    echo '# See https://www.kimai.org/documentation/local-yaml.html' > /config/local.yaml
fi

exec php -S 0.0.0.0:80 -t /app/www/public
