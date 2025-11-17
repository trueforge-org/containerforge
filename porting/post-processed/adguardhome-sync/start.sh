#!/usr/bin/env bash




if [[ ! -f "/config/adguardhome-sync.yaml" ]]; then
    cp -a /defaults/adguardhome-sync.yaml /config/adguardhome-sync.yaml
fi


    
        /config
fi






    exec \
        
             /app/adguardhome-sync/adguardhome-sync run --config "${CONFIGFILE:-/config/adguardhome-sync.yaml}"
else
    exec \
        
            /app/adguardhome-sync/adguardhome-sync run --config "${CONFIGFILE:-/config/adguardhome-sync.yaml}"
fi

