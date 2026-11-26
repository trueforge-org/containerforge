# lancache.net docs: lancache-dns container

Source URL(s): http://lancache.net/docs/containers/dns (upgraded to https). Fetched 2026-11-26.

## Run
- `docker run --name lancache-dns -p 10.0.0.2:53:53/udp -e USE_GENERIC_CACHE=true -e LANCACHE_IP=10.0.0.3 lancachenet/lancache-dns:latest`
- Records generated at container start from uklans/cache-domains list.
- Page mentions only UDP 53 publish (TCP 53 not mentioned; Dockerfile EXPOSEs both).

## Env (page)
- `USE_GENERIC_CACHE`: true to use LANCACHE_IP
- `LANCACHE_IP`: requires USE_GENERIC_CACHE=true
- `${SERVICE}CACHE_IP` (BLIZZARD, FRONTIER, ORIGIN, RIOT, STEAM, UPLAY), space-separated list allowed
- `DISABLE_${SERVICE}=true` (BLIZZARD, RIOT, UPLAY)
- `UPSTREAM_DNS` e.g. 8.8.8.8

## Volumes / paths
- Custom RPZ records: `/etc/bind/cache/custom.db` (bind-mount); format `name A ip`.

## Not stated on page
- User/permissions, healthcheck, restart flags.
