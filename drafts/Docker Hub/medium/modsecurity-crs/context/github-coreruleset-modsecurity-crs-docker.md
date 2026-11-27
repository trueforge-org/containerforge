# github coreruleset/modsecurity-crs-docker

Source URL(s): https://raw.githubusercontent.com/coreruleset/modsecurity-crs-docker/master/README.md (fetched 2026-11-27); https://raw.githubusercontent.com/coreruleset/modsecurity-crs-docker/0148a7443cfa92c9d229b546c89378f548f45410/apache/Dockerfile (pinned commit, fetched 2026-11-27)

## What it is
- OWASP CRS container image: ModSecurity + OWASP CRS on Apache httpd or nginx (also openresty, removed)
- Master README: Apache httpd = ModSecurity v2.9.15 on Apache 2.4.71, CRS 4.30.0; nginx = ModSecurity v3.0.17 on nginx 1.30.7, CRS 4.30.0

## Tags (master README)
- stable: `<CRS>-<webserver>[-<os>]-<YYYYMMDDHHMM>`, e.g. `4.18-nginx-202509051009`
- rolling: `<webserver>[-<os>]` e.g. `nginx`, `apache-alpine` (not for production)
- LTS: `<CRS>-<webserver>[-<os>]-lts`, optional date before `-lts`, e.g. `4.25-nginx-lts`

## Arch
- linux/amd64, linux/arm64 only; linux/i386 no longer published (breaking change, new tags)

## Build (master)
- `docker buildx bake -f ./docker-bake.hcl --print`; `docker buildx bake -f docker-bake.hcl`
- Apache variants use PCRE2 JIT; `apache-no-jit` target exists

## Pinned apache/Dockerfile (commit 0148a744) stages
- build stage: `FROM httpd:${APACHE_VERSION}` (ARG APACHE_VERSION=2.4.57), ARG MODSEC_VERSION=2.9.7; builds SpiderLabs ModSecurity from GitHub tarball, `./configure --with-yajl --with-ssdeep`; installs mod_security2.so
- crs_release stage: ARG CRS_RELEASE; downloads coreruleset v${CRS_RELEASE} tarball + .asc, gpg verify, unpack to /opt/owasp-crs, crs-setup.conf.example -> crs-setup.conf
- final: `FROM httpd:${APACHE_VERSION}`, copies mod_security2.so to /usr/local/apache2/modules, modsecurity.conf-recommended and unicode.mapping to /etc/modsecurity.d, CRS to /opt/owasp-crs, src/etc/modsecurity.d/*.conf, src/bin/* to /usr/local/bin, apache/conf/extra/*.conf
- Note: master README says apache-alpine and nginx variants exist; pinned file is older (ModSecurity 2.9.7, httpd 2.4.57)

## Runtime
- Runs as unprivileged user (httpd and nginx); cannot bind ports <1024 (README). Pinned Dockerfile sets USER=www-data, GROUP=www-data env
- Read-only rootfs variants NOT published (`nginx-read-only` tags do not exist); rootfs is writable per README
- Healthcheck: HTTP 200 from /healthz (added to images)

## Env vars (pinned apache Dockerfile, selection)
| var | default |
| --- | --- |
| PORT | 80 |
| SSL_PORT | 443 |
| BACKEND | http://localhost:80 |
| BACKEND_WS | ws://localhost:8080 |
| PARANOIA | 1 |
| BLOCKING_PARANOIA | 1 |
| ANOMALY_INBOUND | 5 |
| ANOMALY_OUTBOUND | 4 |
| MODSEC_DATA_DIR | /tmp/modsecurity/data |
| MODSEC_TMP_DIR | /tmp/modsecurity/tmp |
| MODSEC_UPLOAD_DIR | /tmp/modsecurity/upload |
| MODSEC_AUDIT_STORAGE | /var/log/modsecurity/audit/ |
| MODSEC_AUDIT_LOG | /dev/stdout |
| MODSEC_RULE_ENGINE | on |
| MODSEC_REQ_BODY_ACCESS | on |
| MODSEC_REQ_BODY_LIMIT | 13107200 |
| MODSEC_RESP_BODY_LIMIT | 1048576 |
| MODSEC_TMP_SAVE_UPLOADED_FILES | on |
| PROXY_SSL | on |
| PROXY_PRESERVE_HOST | on |
| PROXY_TIMEOUT | 60 |
| SERVER_NAME | localhost |
| TIMEOUT | 60 |
| WORKER_CONNECTIONS | 400 |
| LOGLEVEL | warn |
| ACCESSLOG | /var/log/apache2/access.log |
| ERRORLOG | /proc/self/fd/2 |
| METRICS_DENY_FROM | All |
| METRICS_ALLOW_FROM | 127.0.0.0/255.0.0.0 ::1/128 |

## Ports
- 80 (PORT), 443 (SSL_PORT), metrics via METRICS_* (apache)

## Volumes/paths (pinned)
- /usr/local/apache2/conf/server.{key,crt}, /etc/ssl/certs/ca-certificates.crt (PROXY_SSL_*)
- /opt/owasp-crs (rules), /etc/modsecurity.d (config)

## Gotchas
- Master README: `SSL` env vars renamed to file-path vars (`*_KEY` names triggered secret warnings)
- Nginx images now based on upstream nginx; nginx config generated from templates
- Pinned images get no security updates
