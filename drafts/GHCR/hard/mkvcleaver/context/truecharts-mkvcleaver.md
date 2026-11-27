# TrueCharts chart: mkvcleaver

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mkvcleaver/{Chart.yaml,values.yaml} (fetched 2026-11-27)

## What it is
- Chart `mkvcleaver` v17.1.1, appVersion 26.11.2, type application, category media.
- Description: "MKVCleaver is a tool for batch extraction of data from MKV files".
- Depends on `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- Sources listed: ghcr.io/jlesage/mkvcleaver, github.com/jlesage/docker-mkvcleaver.
- kubeVersion >=1.33.0-0; min helm 3.14; max helm 4.1; max k8s 1.35.0.

## Image
- repository: `ghcr.io/jlesage/mkvcleaver`
- tag: `v26.11.2@sha256:b021b93269019be70dc301f626e9aac179be9261eab7c49e4a94cb1caab020b8`
- pullPolicy: IfNotPresent

## Env vars (values.yaml `mkvcleaver:` block -> configmap `mkvcleaver`)
| Key | Default | Notes |
| --- | --- | --- |
| KEEP_APP_RUNNING | false | rendered as "0"/"1" |
| DISPLAY_WIDTH | 1280 | string |
| DISPLAY_HEIGHT | 768 | string |
| SECURE_CONNECTION | false | rendered as "0"/"1" |
| ENABLE_CJK_FONT | false | rendered as "0"/"1" |
| VNC_PASSWORD | from secret `env-secrets` key `VNC_PASSWORD` | via envFrom/secretKeyRef |

## Ports (service)
| Name | Port | Target | Enabled |
| --- | --- | --- | --- |
| main | 5800 | 5800 | yes (web GUI) |
| vnc | 5900 | 5900 | yes |

## Persistence
| Name | mountPath | Enabled |
| --- | --- | --- |
| config | /config | yes |
| storage | /storage | yes |

## Security context (chart values)
- readOnlyRootFilesystem: false; runAsNonRoot: false; runAsUser: 0; runAsGroup: 0.
- capabilities.disableS6Caps: true; add: CHOWN, SETGID, SETUID, FOWNER, DAC_OVERRIDE, KILL, NET_BIND_SERVICE.

## Gotchas
- Chart runs as root (runAsUser 0) and disables s6 capability drop;
- configmap key `envFrom` references configMap named `mkvcleaver`; secret `env-secrets` (VNC_PASSWORD="").
- No healthcheck, probes or user overrides in values.yaml.
