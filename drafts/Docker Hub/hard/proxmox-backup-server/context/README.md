# Context: proxmox-backup-server

| Source URL | File |
| --- | --- |
| https://github.com/ayufan/pve-backup-server-dockerfiles | ayufan-pve-backup-server-readme.md |
| https://github.com/ayufan/pve-backup-server-dockerfiles/blob/v4.2.0-1/dockerfiles/Dockerfile.build | ayufan-dockerfile-build.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/proxmox-backup-server | truecharts-proxmox-backup-server-values.md |
| https://hub.docker.com/r/ayufan/proxmox-backup-server | dockerhub-ayufan-proxmox-backup-server.md |
| https://pbs.proxmox.com/docs | pbs-docs-index.md (includes merged installation + sysadmin follow-ups) |
| https://www.proxmox.com/en/products/proxmox-backup-server/overview | pbs-overview.md |

Skipped categories: none beyond pre-filtering (urls.txt already filtered). Not fetched: PROCESS.md, docker-compose.yml, dockerfiles/ runtime Dockerfile and runit scripts (not linked in urls.txt).
Failures: none.

## plan.md corrections
- None. Checked plan.md against fetched facts (8007 HTTPS port, admin/pbspbs default login, /run tmpfs note, chart persistence paths, Debian trixie base of Dockerfile.build, v4.2.0-1 tag). No edits.
- Unverified in fetched sources (left as is): release publish date 2026-05-15 and asset sizes/digests (API not fetched).
