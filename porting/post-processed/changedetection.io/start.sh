#!/usr/bin/env bash





    
        /config
fi






    exec \
        
            cd /app/changedetection  python3 /app/changedetection/changedetection.py -d /config
else
    exec \
        
            cd /app/changedetection python3 /app/changedetection/changedetection.py -d /config
fi

