#!/usr/bin/env bash




mkdir -p /download
mkdir -p "/run/tomcat.8080"


    # permissions
    
        /config \
        /run/tomcat.8080

    
        /download
fi






    exec \
        
             /usr/bin/java -Djava.io.tmpdir="/run/tomcat.8080" -jar /app/davos/davos.jar
else
    exec \
        
            /usr/bin/java -Djava.io.tmpdir="/run/tomcat.8080" -jar /app/davos/davos.jar
fi

