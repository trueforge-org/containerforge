# ONLYOFFICE/Docker-DocumentServer README

Source URL(s): https://github.com/ONLYOFFICE/Docker-DocumentServer (raw master README) · fetched 2026-11-26

## Run
- `docker run -i -t -d -p 80:80 onlyoffice/documentserver`; custom host port e.g. `-p 8080:80`.
- Editions: Community `onlyoffice/documentserver`; Enterprise `documentserver-ee`; Developer `documentserver-de`.
- Compose: `docker-compose up -d` (community), `docker-compose.enterprise.yml`, `docker-compose.developer.yml`.
- `--env-file` supported.

## Requirements
- RAM 4 GB+; dual-core 2 GHz+; swap 2 GB+; 2 GB+ free disk; 64-bit RHEL/CentOS/Debian/Ubuntu kernel 3.8+; Docker 1.9.0+ (doc cites 20.10.21; base is ubuntu:24.04).

## Ports
- 80 HTTP, 443 HTTPS (LE needs both).

## Volumes
| Path | Purpose |
|---|---|
| /var/log/onlyoffice | logs |
| /var/www/onlyoffice/Data | certificates (certs/) |
| /var/lib/onlyoffice | file cache |
| /var/lib/postgresql | DB (EE/DE compose) |
| /var/lib/rabbitmq | broker (EE/DE compose) |
| /var/lib/redis | cache (EE/DE compose) |
- Community example mounts only logs, Data, lib.

## Env vars (general)
| Name | Default | Meaning |
|---|---|---|
| ONLYOFFICE_HTTPS_HSTS_ENABLED | true | HSTS (SSL only) |
| ONLYOFFICE_HTTPS_HSTS_MAXAGE | 31536000 | HSTS max-age |
| SSL_CERTIFICATE_PATH | /var/www/onlyoffice/Data/certs/tls.crt | |
| SSL_KEY_PATH | .../certs/tls.key | |
| SSL_DHPARAM_PATH | .../certs/dhparam.pem | |
| SSL_VERIFY_CLIENT | off | on/off/optional/optional_no_ca |
| NODE_EXTRA_CA_CERTS | .../certs/extra-ca-certs.pem | |
| NGINX_WORKER_PROCESSES | not stated | |
| NGINX_WORKER_CONNECTIONS | soft ulimit -n | |
| NGINX_ACCESS_LOG | true | |
| SECURE_LINK_SECRET | random | nginx secure_link_md5 |
| JWT_ENABLED | true | |
| JWT_SECRET | random if unset | set explicitly for connectors |
| JWT_HEADER | Authorization | |
| JWT_IN_BODY | false | |
| WOPI_ENABLED | false | |
| IP_FILTER_RULES | unset | `allow <addr>`/`deny <addr>`, semicolon list; no CIDR; WOPI needs allow |
| ALLOW_META_IP_ADDRESS | false | |
| ALLOW_PRIVATE_IP_ADDRESS | false | |
| USE_UNAUTHORIZED_STORAGE | false | self-signed storage certs |
| GENERATE_FONTS | true | regenerate fonts/thumbnails each start (slow) |
| WELCOME_PAGE_ENABLED | true | |
| EXAMPLE_ENABLED | false | |
| METRICS_ENABLED | false | StatsD; METRICS_HOST localhost, METRICS_PORT 8125, METRICS_PREFIX ds. |
| LETS_ENCRYPT_DOMAIN / LETS_ENCRYPT_MAIL | none | |
| PLUGINS_ENABLED | true | |

## Enterprise/Developer-only variables
- ADMINPANEL_ENABLED (true); DB_TYPE (postgres; also mariadb, mysql, dameng, mssql, oracle); DB_HOST, DB_PORT, DB_NAME (must exist), DB_USER, DB_PWD, DB_SCHEMA, DB_TLS_MODE (disable).
- REDIS_TLS_MODE, AMQP_TLS_MODE (disable), TLS_CA_CERT/TLS_CERT/TLS_KEY, AMQP_URI, AMQP_TYPE (rabbitmq|activemq), RABBIT_CONNECTIONS, REDIS_SERVER_HOST/PORT/USER/PASS/DB (0).

## SSL
- Files in `<data>/certs/`: tls.key, tls.crt; optional dhparam.pem. chmod 400 key.
- Self-signed: openssl genrsa/req/x509 (365 days).

## Gotchas
- Documents save only after all users close them; run `documentserver-prepare4shutdown` before stop/update (up to ~5 min).
- RPM hosts: SELinux may block startup (`setenforce 0`); Ubuntu preferred.
- Private/meta IPs blocked by default; WOPI needs IP_FILTER_RULES allow.
- Old Docker versions have compatibility issues with ubuntu:24.04 base.
- IPv6 experimental (Linux only).
