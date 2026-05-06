#!/usr/bin/env bash


# make our folders
mkdir -p \
    /config/www \
    /config/www/local/config \
    /config/gallery/upload \
    /config/gallery/galleries

if [[ -w /app/www/public ]]; then
    # Migrate old data
    if [[ -f /gallery/index.php ]]; then
        echo "*******************************************************************************"
        echo ""
        echo "Migrating old install..."
        mv /gallery/_data/ /config/www/_data
        mv /gallery/language/ /config/www/language
        mv /gallery/plugins/ /config/www/plugins
        mv /gallery/themes/ /config/www/themes
        mv /gallery/local/ /config/www/local
        mv /gallery/template-extension/ /config/www/template-extension
        rm /gallery/index.php
        rm /config/www/gallery
        sed -i "s|root /config/www/gallery;|root /app/www/public;|" /config/nginx/site-confs/default.conf
        echo "Migration completed."
        echo ""
        echo "You can now safely delete everything in /gallery *except* for the upload and"
        echo "galleries directories. If your photos are stored elsewhere you can ignore this."
        echo ""
        echo "*******************************************************************************"
    fi

    shopt -s globstar dotglob

    symlinks=(
        /app/www/public/upload
        /app/www/public/galleries
    )

    for i in "${symlinks[@]}"; do
        if [[ -d /gallery/"$(basename "$i")" && ! -L "$i" ]]; then
            rm -rf "$i"
        fi
        if [[ -d /gallery/"$(basename "$i")" && ! -L "$i" ]]; then
            ln -s /gallery/"$(basename "$i")" "$i"
        fi
    done

    symlinks=(
        /app/www/public/language
        /app/www/public/plugins
        /app/www/public/local
        /app/www/public/themes
        /app/www/public/_data
        /app/www/public/template-extension
    )

    for i in "${symlinks[@]}"; do
        if [[ -d /config/www/"$(basename "$i")" && ! -L "$i" ]]; then
            rm -rf "$i"
        fi
        if [[ ! -d /config/www/"$(basename "$i")" && ! -L "$i" ]]; then
            mv "$i" /config/www/
        fi
        if [[ -d /config/www/"$(basename "$i")" && ! -L "$i" ]]; then
            ln -s /config/www/"$(basename "$i")" "$i"
        fi
    done

    shopt -u globstar dotglob
fi

# copy config
if [[ ! -f "/config/www/local/config/config.inc.php" ]]; then
    cp /app/www/public/include/config_default.inc.php /config/www/local/config/config.inc.php
fi

cd /app/www/public
exec php -S 0.0.0.0:80
