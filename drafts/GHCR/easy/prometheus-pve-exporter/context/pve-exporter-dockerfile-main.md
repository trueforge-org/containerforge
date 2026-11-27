# prometheus-pve-exporter Dockerfile (main branch)

## Source URL(s) + date
- https://raw.githubusercontent.com/prometheus-pve/prometheus-pve-exporter/main/Dockerfile (fetched 2026-11-27)
- Blob URL `blob/main` referenced in the plan is the github.com view of the same file (not fetched separately)

## Differences vs pinned commit 9c46938 (`pve-exporter-dockerfile-9c46938.md`)
- Base image: `alpine:3.24.4` (pinned commit uses 3.24.3)
- Otherwise identical: same packages, same pip wheel/build steps, same venv at /opt/prometheus-pve-exporter, same user prometheus uid/gid 101, USER prometheus, EXPOSE 9221, ENTRYPOINT pve_exporter

## Gotchas
- Chart pins image 3.12.0 (digest). Which commit that image was built from was not verified, so the Alpine base (3.24.3 vs 3.24.4) for that image is unverified.
