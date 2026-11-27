# Dispatcharr docker-compose.aio.yml

Source URL: https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/main/docker/docker-compose.aio.yml (raw variant of the blob URL in urls.txt; fetched 2026-11-27)

## Service
- image: `ghcr.io/dispatcharr/dispatcharr:latest` (build block commented out: context ., dockerfile Dockerfile)
- restart: unless-stopped; container_name dispatcharr
- ports: `9191:9191`
- volume: named `dispatcharr_data:/data`

## Env (set)
| Name | Value |
| --- | --- |
| DISPATCHARR_ENV | aio |
| REDIS_HOST | localhost |
| CELERY_BROKER_URL | redis://localhost:6379/0 |
| DISPATCHARR_LOG_LEVEL | info |

## Env (commented optional)
| Name | Default / note |
| --- | --- |
| DISPATCHARR_PORT | 9191; must match container port in ports |
| REDIS_IDLE_TIMEOUT | 300 |
| REDIS_MAX_CONNECTIONS | 50 |
| DISPATCHARR_SETUP_ALLOWED_IP | unset: only private/local networks may POST initialize-superuser |
| DISPATCHARR_TRUSTED_PROXIES | unset: private/loopback trusted for proxy headers; `none` ignores |
| USE_LEGACY_NUMPY | true for old CPUs |
| UWSGI_NICE_LEVEL | 0 (recommended -5; negative needs cap_add SYS_NICE) |
| CELERY_NICE_LEVEL | 5 |
| UWSGI_WORKERS | 4 |
| CELERY_MAX_WORKERS | 6 |
| CELERY_MIN_WORKERS | 1 (must be <= max) |
| DISPATCHARR_NOFILE | 65536 |

## Devices / caps (commented)
- cap_add: SYS_NICE (for negative nice levels)
- devices: `/dev/dri:/dev/dri` (VA-API GPU)
- NVIDIA GPU reservation via deploy.resources (nvidia, count all, capabilities gpu)

## Gotchas
- REDIS_HOST=localhost and CELERY_BROKER_URL on localhost imply redis runs inside the container (inference from env values; not stated in the file).
