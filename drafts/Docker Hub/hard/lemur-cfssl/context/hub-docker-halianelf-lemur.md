# Docker Hub: halianelf/lemur

Source URL(s): https://hub.docker.com/r/halianelf/lemur. Fetched 2026-11-26.

- Bundles Lemur + CFSSL (Cloudflare PKI toolkit, CLI and HTTP API). Third-party image (publisher halianelf).
- Tags: `latest` only. Size ~282 MB. Last updated ~7 years before snapshot. 50K+ pulls.
- Pull: `docker pull halianelf/lemur`. Architectures not stated.
- Create: `docker create --name=lemur -v <config>:/config -v <data>:/data -e PGID=<gid> -e PUID=<uid> -p 80:80 halianelf/lemur`
- Ports: 80 (web UI). Volumes: `/config` (Lemur + CFSSL config), `/data` (Postgres data).
- After first start, CFSSL templates in `/config/cfssl`: remove `.tmpl` suffix and restart to generate certs. Intermediate length in `root_to_intermediate_ca.json`. Lemur config at `/config/lemur/lemur.conf.py`.
- Default login lemur / password (change in UI). CFSSL must be added as an authority in Lemur after cert creation.
- Shell: `docker exec -it lemur /bin/bash`; logs `docker logs -f lemur`.
