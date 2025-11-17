#!/usr/bin/env bash




if [[ -z ${DB_TYPE} ]]; then
    printf "sqlite" > /run/s6/container_environment/DB_TYPE
fi

if [[ ! -f "/config/config.yml" ]]; then
    cp /defaults/config.yml /config/config.yml
fi


    # permissions
    
        /config

    if grep -qe ' /data ' /proc/mounts; then
        
            /data
    fi
fi





export CONFIG_FILE="/config/config.yml"


    exec \
        
            cd /app/wiki  /usr/bin/node server
else
    exec \
        
            cd /app/wiki /usr/bin/node server
fi

