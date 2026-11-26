# WeblateOrg/docker README (summary)

Source URL: https://raw.githubusercontent.com/WeblateOrg/docker/master/README.md (fetched 2026-11-26)

- Official Docker image; nginx built in; Celery workers; port 8080.
- Deployment options: WeblateOrg/docker-compose; OpenShift; Helm chart (hub.helm.sh/charts/weblate/weblate). Full docs: docs.weblate.org/en/latest/admin/install/docker.html

## Env
| Var | Default | Behavior |
| --- | --- | --- |
| WEBLATE_IP_PROXY_HEADER | not stated | Django META name, e.g. `HTTP_X_FORWARDED_FOR`, `HTTP_X_REAL_IP`, `HTTP_CF_CONNECTING_IP` |
| WEBLATE_TRUSTED_PROXY_ADDRESSES | empty (immediate TCP peer) | Whitespace-separated IPs/networks/hostnames of trusted proxies |
| WEBLATE_IP_PROXY_OFFSET | effective 0 in proxy mode | nginx forwards one normalized address |
| WEBLATE_WORKERS | unset (auto) | Positive decimal int, max 18 significant digits |
| WEBLATE_ASGI | 0 | 0 or 1; other values fail startup |
| CELERY_COMBINED_OPTIONS | auto | Override, e.g. `--concurrency 2` |

- Celery combined default: 3 x WEBLATE_WORKERS capped by RAM. Capacity = min(host RAM, cgroup limits). Half RAM reserved for web; 512 MiB per Celery child. Min concurrency 1.
- Tests: `./tests/run` (needs python3, bash, jq; docker/cosign mocked).
- Volumes, user/UID, healthcheck: not stated.
