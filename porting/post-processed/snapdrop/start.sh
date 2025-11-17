#!/usr/bin/env bash




# permissions

    /config





cd /app/www/server || exit 1

exec \
     /usr/bin/node index.js

