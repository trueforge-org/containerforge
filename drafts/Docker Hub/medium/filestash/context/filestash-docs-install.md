# filestash.app install and upgrade docs

Source URL(s): https://www.filestash.app/docs (landing only, fetched) ; https://www.filestash.app/docs/install-and-upgrade/ (fetched)
Date: fetched 2026-11-26

- Landing page: self-host or hosted demo (demo.filestash.app). No install details.
- Target: Linux server; "1 core, 128MB of RAM is plenty".
- Binary: `curl -o filestash.bin https://downloads.filestash.app/latest/filestash_linux_$(uname -m).bin`; `chmod +x`; `./filestash.bin`. Listens `:8334`.
- Docker Compose: `curl -O https://downloads.filestash.app/latest/docker-compose.yml`; `docker compose up -d`. Creates volume `filestash_filestash` and containers `filestash` + `filestash_wopi`. Docker build is heavier, includes C deps for thumbnails/transcoding.
- Other envs (K8s, RHEL, air-gapped, Windows, old libc): contact support; Helm guide at /docs/guide/helm.html.
- Port 8334 HTTP; TLS via reverse proxy, or direct certs, or ACME (/ssl-setup.html).
- Env: `ADMIN_PASSWORD` = bcrypt hash (optional, skips setup screen).
- Upgrade (compose): re-download compose file, `docker-compose pull`, `docker-compose up -d`. No binary upgrade steps.
- Not on page: docker run flags, config path, UID, healthcheck, env defaults.
