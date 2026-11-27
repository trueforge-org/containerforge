# TrueCharts chart: poznote (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/poznote/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/poznote/Chart.yaml (2026-11-27)

What it is: "Poznote is a self-hosted note-taking and knowledge base application with a web editor, attachments, snapshots, backups and optional OIDC authentication." Chart `version: 3.2.0`, `appVersion: 6.160.1`. Category productivity. Depends on `common` (oci://oci.trueforge.org/truecharts).

Image (values.yaml):
- repository `ghcr.io/timothepoznanski/poznote`
- tag `6.160.1-rootless@sha256:f34667a1a3f4802354b5ae5ef47ae7c9c3af3d1d08bac2d8a3ad8e0cdac9b138`
- pullPolicy IfNotPresent

Ports: service main, port 8080 (targetPort default).

Volumes/paths:
| Name | Path | Type | Workloads |
| --- | --- | --- | --- |
| data | `/var/www/html/data` | PVC (chart default) | main, prepare-runtime |
| run | `/run` | emptyDir | main, prepare-runtime |
| nginx | `/var/lib/nginx` | emptyDir | main, prepare-runtime |
| varlog | `/var/log` | emptyDir | main, prepare-runtime |
| varrun | chart `/var/run` emptyDir | disabled (masks `/run` through symlink) | - |

User/UID: chart uses uid/gid 568 for runtime (per comment). The `prepare-runtime` init container runs as root (`runAsUser 0`, `runAsGroup 0`, `runAsNonRoot false`, `readOnlyRootFilesystem true`, `allowPrivilegeEscalation false`). Main container runs as 568 per chart comment and plan.

Init container `prepare-runtime` (type init, image `ubuntuImage`): `mkdir -p /run/nginx /var/lib/nginx/logs /var/lib/nginx/tmp/{client_body,fastcgi,proxy,uwsgi,scgi} /var/log/nginx /var/log/supervisor`, then `chown -R 568:568 /run/nginx /var/lib/nginx /var/log /var/www/html/data`.

Probes (main): liveness, readiness, startup all `type: http`, `path: /api/health`.

Gotchas:
- Chart runs the rootless image variant (`-rootless` tag), not the default image.
- Chart pins appVersion `6.160.1`; the GitHub latest release seen 2026-11-27 is `6.161.0` (see github-poznote-repo.md).
