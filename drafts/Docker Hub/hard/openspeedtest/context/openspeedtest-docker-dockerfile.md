# openspeedtest/Docker-Image Dockerfile

Source URL(s): https://github.com/openspeedtest/Docker-Image/blob/main/Dockerfile (raw fetched) · fetched 2026-11-26

- `FROM docker.io/nginx/nginx-unprivileged:stable-alpine`. LABEL maintainer OpenSpeedTest.com.
- ENV defaults: ENABLE_LETSENCRYPT=false; DOMAIN_NAME=false; USER_EMAIL=false; CONFIG=/etc/nginx/conf.d/OpenSpeedTest-Server.conf; INDEX_HTML=/usr/share/nginx/html/index.html; CHANGE_CONTAINER_PORTS=false; HTTP_PORT=3000; HTTPS_PORT=3001; SET_USER=101.
- COPY: files/OpenSpeedTest-Server.conf -> $CONFIG; files/entrypoint.sh -> /entrypoint.sh; files/renew.sh -> /renew.sh; files/nginx.conf -> /etc/nginx/; files/www/ -> /usr/share/nginx/html/; files/nginx.crt and nginx.key -> /etc/ssl/ (committed public key pair).
- USER root; VOLUME /var/log/letsencrypt.
- RUN: remove /etc/nginx/nginx.conf; remove conf.d/default.conf; chown nginx html; chmod 755 html/downloading and html/upload; chown/chmod conf and nginx.conf (400); CRLF->LF for entrypoint.sh and renew.sh; chmod +x; mkdir and chown/chmod 775 for /etc/letsencrypt, /var/lib/letsencrypt, /var/log/letsencrypt, /usr/share/nginx/html/.well-known/acme-challenge.
- apk: ca-certificates, certbot, certbot-nginx, dcron, libcap; update-ca-certificates; setcap cap_setgid=ep /usr/sbin/crond; /etc/crontabs/nginx owned by nginx.
- USER ${SET_USER} (101); EXPOSE ${HTTP_PORT} ${HTTPS_PORT}; STOPSIGNAL SIGQUIT; CMD ["/entrypoint.sh"]. No ENTRYPOINT, WORKDIR, HEALTHCHECK.
- No downloads outside apk.
