# TrueCharts ztcuui-aio (chart page)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ztcuui-aio/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ztcuui-aio/Chart.yaml
- Fetched 2026-11-27 (master)

## What it is
- Chart `ztcuui-aio` v14.0.0, appVersion 2024.1.28. "ZeroTier network controller user interface in a Docker container".
- Dependency `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`. kubeVersion `>=1.33.0-0`.

## Image
- `ghcr.io/kmahyyg/ztncui-aio`, tag `v2024.1.28-r1@sha256:7554973386b164f446df0c731a0445c76bac4980f862c4b5eb71d3683315c400`, pullPolicy IfNotPresent.

## Ports
| Service | Port name | Port | targetPort | Proto |
| --- | --- | --- | --- | --- |
| main | main | 10258 | not set | TCP (HTTP_PORT templated from it) |
| server | web | 3180 | 3180 | TCP |
| planet | planet | 9993 | 9993 | UDP |

## Env (main)
| Var | Value |
| --- | --- |
| HTTP_PORT | templated from service `main` port |
| HTTP_ALL_INTERFACES | `yes` |
| NODE_ENV | `production` |
| MYDOMAIN | `test.truecharts.org` |
| ZTNCUI_PASSWD | secretKeyRef `env-secrets` / `ZTNCUI_PASSWD` (secret default `CHANGEME`) |

## Volumes (chart mountPaths)
- config: `/opt/key-networks/ztncui/etc`
- zerotier: `/var/lib/zerotier-one`
- mkworld: `/etc/zt-mkworld`

## Probes
- None defined.

## User/UID
- Container: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.

## Host access
- No hostNetwork/privileged/device settings.
