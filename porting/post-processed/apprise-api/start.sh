#!/usr/bin/env bash





    
        /config
fi






    exec \
        
        cd /app/apprise-api/apprise_api  /usr/sbin/uwsgi --http-socket=:8000 --enable-threads --plugin=python3 --module=core.wsgi:application --static-map=/s=static --buffer-size=32768 -H /lsiopy
else
    exec \
        
        cd /app/apprise-api/apprise_api /usr/sbin/uwsgi --http-socket=:8000 --enable-threads --plugin=python3 --module=core.wsgi:application --static-map=/s=static --buffer-size=32768 -H /lsiopy
fi

