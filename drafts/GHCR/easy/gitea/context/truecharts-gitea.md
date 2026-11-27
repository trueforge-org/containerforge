# TrueCharts gitea (stable)

## Source URL(s) + date

- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gitea/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gitea/Chart.yaml
- Fetched 2026-11-27

## What it is

- Chart `gitea` v28.0.0, appVersion 28.4.0. "Self hosted GIT repositories". Category GIT.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image

| Key | Value |
| --- | --- |
| repository | `ghcr.io/go-gitea/gitea` |
| tag | `28.4.0-rootless@sha256:15ab7fadb44981a2b781f40c712cad07066197f395100ea1c6326e14e5bb073a` |
| pullPolicy | IfNotPresent |

- Upstream image is GHCR only (no Docker Hub image in chart).

## Ports

| Name | Container | Service port | Notes |
| --- | --- | --- | --- |
| main | 3000 | 10037 | web UI |
| ssh | 2222 | 2222 | `service.ssh.enabled: true` |

- Metrics: `metrics.main` enabled, endpoint port `main`, path `/metrics` (ServiceMonitor).

## Volumes / paths

| Name | Mount | Type |
| --- | --- | --- |
| data | `/data` | persistent (targetSelectAll) |
| varlib | `/var/lib/gitea` | emptyDir |

- `signing.gpgHome: /data/git/.gnupg`.

## Env / config (chart-provided)

| Key | Value |
| --- | --- |
| config.APP_NAME | `Gitea: Git with a cup of tea` |
| config.RUN_MODE | `dev` |
| config.ALLOWED_HOST_LIST | `127.0.0.1` |
| config.nodeIP | `127.0.0.1` |
| admin.username | `giteaadmin` |
| admin.email | `gitea@local.domain` |
| admin.passwordMode | `keepUpdated` (options: initialOnlyNoReset, initialOnlyRequireReset, keepUpdated) |
| admin.existingSecret | commented out |

- Values file contains a hardcoded admin password (not recorded here).
- ldap, oauth: disabled by default.
- `customConfig: []`.

## Dependencies (chart)

- postgresql: enabled; username `gitea`, database `gitea`.
- memcached: enabled.

## User / UID

- `securityContext.container.runAsUser: 1000`, `runAsGroup: 1000`.
- `securityContext.pod.fsGroup: 1000`.

## Init containers (chart)

- `1-init-directories`: runs as uid 0, command `/usr/sbin/init_directory_structure.sh`, envFrom configMap `gitea-env`.
- `2-configure-gitea`: command `/usr/sbin/configure_gitea.sh`, envFrom configMap `gitea-env`.
- These are chart-specific scripts, not in upstream image.

## Healthcheck / probes

- liveness, readiness, startup: all `type: tcp` (main container).

## Gotchas

- Chart runs init containers that call chart-only scripts; ContainerForge image must not depend on them.
- Chart enables postgres + memcached dependencies; the container itself does not bundle them.
