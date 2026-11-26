# lancache.net docs: monolithic container

Source URL(s): http://lancache.net/docs/containers/monolithic (upgraded to https). Fetched 2026-11-26.

## Run
- `docker run --restart unless-stopped --name lancache -v /cache/data:/data/cache -v /cache/logs:/data/logs -p 80:80 -p 443:443 lancachenet/monolithic:latest`
- HTTP must reach the container (DNS entries pointing game services at cache host; lancache-dns or existing DNS).
- 443 mapped but HTTPS is NOT cached (proxied uncached). Port 53 not stated (separate lancache-dns container).

## Volumes / paths
- `/data/cache` persistent cache; `/data/logs` logs (optional). Access log `/data/logs/access.log`.

## Env (page)
| Var | Default |
| --- | --- |
| UPSTREAM_DNS | `8.8.8.8 8.8.4.4` (whitespace separated) |
| CACHE_MEM_SIZE | 500m (nginx cache manager memory; ~1 MB per 8 GB disk) |
| CACHE_DISK_SIZE | 1000g |
| CACHE_MAX_AGE | 3560d |

- nginx notation for sizes (m/g) and durations (m/h/d).
- Not stated on page: CACHE_ROOT, CACHE_INDEX_SIZE, MIN_FREE, LANCACHE_IP.

## Other
- Services listed: Steam, Origin, Riot, Battle.net, Frontier, Uplay, Windows Updates; caches all uklans cache-domains CDNs.
- Not stated: user/permissions, healthcheck.
