# binwiederhier/ntfy (Docker Hub)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/binwiederhier/ntfy (fetched 2026-11-26)

**Version/release info and asset naming**
- Only tag shown: `latest` (digest begins `sha256:ca35419d2...`, size about 35.3 MB). Chart pins `v2.38.2@sha256:ca35419d29a834824db2440fa9320897fbe40b026c5fc2360c76ed3501b5e716`.
- Last updated shown as 2 days before the fetch.

**Arch support**
- amd64, armv7, arm64 (page). Install docs also list armv6.

**Install/run**
- `docker run -p 80:80 -it binwiederhier/ntfy serve`
- Persistent cache: `-v /var/cache/ntfy:/var/cache/ntfy` with `--cache-file /var/cache/ntfy/cache.db serve`.
- Custom config: `-v /etc/ntfy:/etc/ntfy`.
- Custom image: `FROM binwiederhier/ntfy`, copy `server.yml` to `/etc/ntfy/server.yml`, `ENTRYPOINT ["ntfy", "serve"]`.

**Ports and volumes**
- Port 80 (web UI and API). Volumes: `/var/cache/ntfy` (cache), `/etc/ntfy` (config).

**Env vars**
- None listed on the page.

**Gotchas**
- Page describes the image as bundling the server and a CLI client.
