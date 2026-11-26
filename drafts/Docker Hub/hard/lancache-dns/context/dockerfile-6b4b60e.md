# lancachenet/lancache-dns Dockerfile (commit 6b4b60e)

Source URL(s): https://raw.githubusercontent.com/lancachenet/lancache-dns/6b4b60e/Dockerfile (blob: https://github.com/lancachenet/lancache-dns/blob/6b4b60e/Dockerfile). Fetched 2026-11-26.

## Stage 1: builder-dnstool
- `FROM golang:1.27-alpine`, WORKDIR `/go/src/`
- apk `git` (--no-cache); git clone `https://github.com/lancachenet/dnstool.git` (no pinned tag/commit)
- `CGO_ENABLED=0 go build -trimpath -ldflags "-s -w"` -> `/go/src/dnstool`

## Stage 2: final
- `FROM lancachenet/ubuntu:latest` (no digest; DL3007 ignored)
- LABEL `org.opencontainers.image.authors="LanCache.Net Team <team@lancache.net>"`
- ENV: `STEAMCACHE_DNS_VERSION=1`, `ENABLE_DNSSEC_VALIDATION=false`, `LANCACHE_DNSDOMAIN=cache.lancache.net`, `CACHE_DOMAINS_REPO=https://github.com/uklans/cache-domains.git`, `CACHE_DOMAINS_BRANCH=master`, `UPSTREAM_DNS=8.8.8.8`
- RUN apt: `apt-get update && apt-get -y upgrade`; `apt-get install -y bind9 ca-certificates curl dnsutils git --no-install-recommends` (DL3008 ignored); clean; rm `/var/lib/apt/lists/*`
- `mkdir -p /var/cache/bind /var/log/named`; chown bind:bind
- `git clone --depth=1 --no-single-branch https://github.com/uklans/cache-domains.git /opt/cache-domains` (HARDCODED, ignores CACHE_DOMAINS_REPO)
- `COPY --link overlay/ /`; `COPY --link --from=builder-dnstool /go/src/dnstool /usr/local/bin/dnstool`
- EXPOSE `53/udp`, `53/tcp`
- WORKDIR `/scripts`
- HEALTHCHECK interval 30s, timeout 5s, start-period 30s: `dig +time=2 +tries=1 +norecurse @127.0.0.1 . NS | grep -q 'status: NOERROR'`
- Not present: USER, VOLUME, ENTRYPOINT, CMD, ARG. Startup is via overlay (not shown).
- Uses heredoc RUN syntax (BuildKit required).
