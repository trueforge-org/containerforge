# GitHub: openhab-docker debian/Dockerfile (pinned commit 045c5cfacb270a668f3384990b4dcc91235d109f)
Source URL(s): https://raw.githubusercontent.com/openhab/openhab-docker/045c5cfacb270a668f3384990b4dcc91235d109f/debian/Dockerfile (fetched 2026-11-27)

## Build
- Stage 1 su-exec-builder: debian:13-slim, curl su-exec.c @ ncopa/su-exec 4c3bb42 (sha256 d6c404...b82891 verified), gcc build
- Stage 2: debian:13-slim, COPY --from builder /su-exec /sbin/su-exec
- apt: adduser arping ca-certificates curl fontconfig iputils-ping libcap2-bin locales locales-all netbase procps tini unzip wget zip
- JRE: openjdk-${JAVA_VERSION}-jre-headless else temurin-${JAVA_VERSION}-jre (packages.adoptium.net)
- nodejs installed when OPENHAB_VERSION major >= 5
- crypto.policy sed unlimited -> limited in java.security
- Distro: wget openhab-${version}.zip (milestone: openhab.jfrog.io libs-milestone-local; SNAPSHOT 5.x: ci.openhab.org; else libs-release); unzip excluding *.bat *.ps1 *.psm1 into /openhab
- Copies conf and userdata to /openhab/dist
- COPY update -> /openhab/runtime/bin/update

## Env (ENV block)
CRYPTO_POLICY=limited, EXTRA_JAVA_OPTS="", EXTRA_SHELL_OPTS="", GROUP_ID=9001, USER_ID=9001, KARAF_EXEC=exec, OPENHAB_HTTP_PORT=8080, OPENHAB_HTTPS_PORT=8443, OPENHAB_HOME=/openhab, OPENHAB_CONF=/openhab/conf, OPENHAB_USERDATA=/openhab/userdata, OPENHAB_LOGDIR=/openhab/userdata/logs, OPENHAB_BACKUPS=/openhab/userdata/backup, TZ=Etc/UTC, LANG/LC_ALL/LANGUAGE=en_US.UTF-8

## Runtime
- EXPOSE 8080 8443 8101 5007
- VOLUME /openhab/conf /openhab/userdata /openhab/addons
- HEALTHCHECK 1m/10s/3 retries/20m start-period: curl -f http://localhost:${OPENHAB_HTTP_PORT}/
- WORKDIR /openhab; ENTRYPOINT ["/entrypoint"]; CMD ["su-exec","openhab","tini","-s","./start.sh"]
- setuid on /bin/ping and /usr/sbin/arping; chfn -> /bin/true
- Build args: BASE_IMAGE, BUILD_DATE, VCS_REF, JAVA_VERSION, OPENHAB_VERSION
- Labels: licenses EPL-2.0, source github.com/openhab/openhab-docker.git
