# ONLYOFFICE/Docker-DocumentServer Dockerfile

Source URL(s): https://github.com/ONLYOFFICE/Docker-DocumentServer/blob/master/Dockerfile (raw fetched) · fetched 2026-11-26

- Syntax `docker/dockerfile:1`. `FROM ubuntu:24.04`. LABEL maintainer Ascensio System SIA.
- ENV: LC_ALL=en_US.UTF-8, LANGUAGE=en_US:en, DEBIAN_FRONTEND=noninteractive, DS_PLUGIN_INSTALLATION=false, DS_DOCKER_INSTALLATION=true, COMPANY_NAME, PRODUCT_NAME, PRODUCT_EDITION (from ARGs).
- ARG: COMPANY_NAME=onlyoffice; PRODUCT_NAME=documentserver; PRODUCT_EDITION (empty); PACKAGE_VERSION (empty); TARGETARCH; PACKAGE_BASEURL=https://download.onlyoffice.com/install/documentserver/linux.
- RUN #1: policy-rc.d exit 101; apt install ca-certificates curl gnupg locales sudo cron certbot python3-certbot-nginx netcat-openbsd supervisor; locale-gen; clean lists.
- COPY fonts/ -> /usr/share/fonts/truetype/; config/supervisor/ -> /etc/supervisor/conf.d/ (excluding ds-adminpanel.conf, ds.conf.enterprise); run-document-server.sh -> /app/ds/.
- RUN #2: package file `${COMPANY_NAME}-${PRODUCT_NAME}${PRODUCT_EDITION}[_$PACKAGE_VERSION]_${arch}.deb`; fails if PRODUCT_EDITION non-empty; curl to /tmp; GPG key https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE -> /usr/share/keyrings/onlyoffice.gpg; apt source `deb [signed-by=...] https://download.onlyoffice.com/repo/debian squeeze main`; msttcorefonts EULA preseeded; apt install local .deb; rm sites-enabled/default; sed COMPANY_NAME placeholder in supervisor confs; require >=30 .ttf in /usr/share/fonts/truetype/msttcorefonts; remove .deb, /var/log/$COMPANY_NAME, apt lists.
- EXPOSE 80 443.
- VOLUME /var/log/$COMPANY_NAME, /var/lib/$COMPANY_NAME, /var/www/$COMPANY_NAME/Data, /usr/share/fonts/truetype/custom.
- HEALTHCHECK interval 30s, timeout 10s, start-period 60s, retries 5; if ONLYOFFICE_DATA_CONTAINER != true: `curl -fs http://127.0.0.1/healthcheck` must print `true`.
- ENTRYPOINT ["/app/ds/run-document-server.sh"]. No WORKDIR, USER, CMD, ADD; runs as root.
