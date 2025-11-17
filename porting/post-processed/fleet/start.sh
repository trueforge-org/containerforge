#!/usr/bin/env bash





    
        /config
fi






    exec \
        
             /usr/bin/java -Dfleet.config.base=/config -Dlog4j2.formatMsgNoLookups=true -jar /app/fleet/fleet.jar
else
    exec \
        
            /usr/bin/java -Dfleet.config.base=/config -Dlog4j2.formatMsgNoLookups=true -jar /app/fleet/fleet.jar
fi

