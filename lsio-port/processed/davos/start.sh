# ===== From ./processed/davos/root/etc/s6-overlay//s6-rc.d/init-davos-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p /download
mkdir -p "/run/tomcat.8080"

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    # permissions
    lsiown -R abc:abc \
        /config \
        /run/tomcat.8080

    lsiown abc:abc \
        /download
fi

# ===== From ./processed/davos/root/etc/s6-overlay//s6-rc.d/svc-davos/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8080" \
            s6-setuidgid abc /usr/bin/java -Djava.io.tmpdir="/run/tomcat.8080" -jar /app/davos/davos.jar
else
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8080" \
            /usr/bin/java -Djava.io.tmpdir="/run/tomcat.8080" -jar /app/davos/davos.jar
fi

