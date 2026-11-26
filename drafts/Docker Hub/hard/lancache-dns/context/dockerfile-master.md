# lancachenet/lancache-dns Dockerfile (master)

Source URL(s): https://raw.githubusercontent.com/lancachenet/lancache-dns/master/Dockerfile (blob: https://github.com/lancachenet/lancache-dns/blob/master/Dockerfile). Fetched 2026-11-26.

- Same structure as the 6b4b60e pinned file (see dockerfile-6b4b60e.md): builder-dnstool on golang:1.27-alpine; final `lancachenet/ubuntu:latest`; same ENV defaults; same apt set (bind9, ca-certificates, curl, dnsutils, git); cache-domains cloned to /opt/cache-domains; EXPOSE 53/udp 53/tcp; WORKDIR /scripts; same HEALTHCHECK.
- Differences vs pinned: none identified in fetched summary.
