# lancache.net docs: monolithic variables

Source URL(s): https://lancache.net/docs/containers/monolithic/variables/. Fetched 2026-11-26.

Note: CACHE_ROOT, LANCACHE_IP, CACHE_MEM_SIZE not listed on this page (CACHE_MEM_SIZE is listed on the docs index page as 500m).

## General
| Var | Default | Meaning |
| --- | --- | --- |
| CACHE_DOMAINS_REPO | https://github.com/uklans/cache-domains.git | test-only override |
| CACHE_DOMAINS_BRANCH | master | branch |
| NOFETCH | false | disable git pulls, use stored data |
| UPSTREAM_DNS | `8.8.8.8 8.8.4.4` | separated by `;` or space; not lancache-dns |
| CACHE_DISK_SIZE | 1000g | GB the cache may use |
| CACHE_INDEX_SIZE | 500m | nginx index memory; ~250m per 1 TB disk |
| CACHE_MAX_AGE | 3560d | max cache age |
| MIN_FREE_DISK | 10g | prune when free space below this |

## Advanced (change only if advised)
| Var | Default | Meaning |
| --- | --- | --- |
| NGINX_WORKER_PROCESSES | auto (page also lists 16) | no description |
| GENERICCACHE_VERSION | 2 | internal, do not change |
| WEBUSER | www-data | nginx account |
| BEAT_TIME | 1h | heartbeat frequency |
| LOGFILE_RETENTION | 3560 | no description |
| CACHE_SLICE_SIZE | 1m | changing invalidates cache |
| CACHE_MODE | generic | no description (Dockerfile sets monolithic) |
| FORCE_PERMS_CHECK | false | full perms check at start, may take hours |

## Changing
- Env change = recreate container; cache in external volume reused. Compose: `.env`; CLI: `-e`.
