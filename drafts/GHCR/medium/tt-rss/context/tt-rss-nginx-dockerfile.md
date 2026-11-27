# tt-rss web-nginx Dockerfile (.docker/web-nginx)

Source URL(s): https://raw.githubusercontent.com/tt-rss/tt-rss/d62bcf96d01a7a2e750f6c9581ca462556e57281/.docker/web-nginx/Dockerfile (fetched 2026-11-27)

## What it is
- nginx front for tt-rss (GHCR ghcr.io/tt-rss/tt-rss-web-nginx), FastCGI proxy to the app container.

## Build
- `FROM nginx:1.31.8-alpine`.
- COPY .docker/web-nginx/nginx.conf -> /etc/nginx/templates/nginx.conf.template (envsubst by official nginx image).

## Args / env
| Var | Default |
| --- | --- |
| APP_UPSTREAM (ARG+ENV) | app |
| APP_FASTCGI_PASS | \$backend |
| APP_WEB_ROOT | /var/www/html |
| APP_BASE | /tt-rss |
| RESOLVER | 127.0.0.11 |
| NGINX_ENVSUBST_OUTPUT_DIR | /etc/nginx |

- Non-root base-path override: APP_WEB_ROOT=/var/www/html/tt-rss, APP_BASE="" puts app at site root.

## Entrypoint / Ports
- Inherits nginx image entrypoint/CMD. Port from nginx.conf template (not fetched; chart sets listen port via configmap).

## Healthcheck
- `curl --fail --silent --show-error http://localhost${APP_BASE}/index.php` every 30s, timeout 10s, start 5s, retries 3.

## Gotchas
- Chart overrides nginx config with its own configmap template (chart uses `/public.php?op=healthcheck`).
