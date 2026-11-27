# TrueCharts chart: mkvtoolnix

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mkvtoolnix/{Chart.yaml,values.yaml} (fetched 2026-11-27)

## What it is
- Chart `mkvtoolnix` v18.1.1, appVersion 26.11.2, type application, category media.
- Description: "MKVToolNix is a set of tools to create, alter and inspect Matroska files."
- Depends on `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- Sources: ghcr.io/jlesage/mkvtoolnix, github.com/jlesage/docker-mkvtoolnix, mkvtoolnix.download.
- kubeVersion >=1.33.0-0; min helm 3.14; max helm 4.1; max k8s 1.35.0.

## Image
- repository: `ghcr.io/jlesage/mkvtoolnix`
- tag: `v26.11.2@sha256:9da6a9884a966b7ecd86e505468f97f31c83810e9c83512db2ecaad02432d787`
- pullPolicy: IfNotPresent

## Service ports
| Name | port (svc) | targetPort | Enabled |
| --- | --- | --- | --- |
| main | 10236 | 5800 | yes |
| vnc | 10237 | 5900 | yes |

## Env vars (configmap `mkvtoolnix`, values `mkvtoolnix:` block)
| Key | Default | Notes |
| --- | --- | --- |
| KEEP_APP_RUNNING | false | "0"/"1" |
| DISPLAY_WIDTH | 1280 | string |
| DISPLAY_HEIGHT | 768 | string |
| DARK_MODE | false | "0"/"1" |
| SECURE_CONNECTION | false | "0"/"1" |
| ENABLE_CJK_FONT | false | "0"/"1" |
| VNC_PASSWORD | secret `env-secrets` key `VNC_PASSWORD` | secretKeyRef |

## Persistence
| Name | mountPath |
| --- | --- |
| config | /config |
| storage | /storage |

## Security / probes
- securityContext: readOnlyRootFilesystem false; runAsNonRoot false; runAsUser 0; runAsGroup 0.
- main container caps add: NET_BIND_SERVICE, KILL.
- Probes: liveness, readiness, startup all `type: tcp` (no port override; default service port).

## Gotchas
- Chart runs as root; differs from ContainerForge target (USER apps).
- Chart service ports (10236/10237) differ from container ports (5800/5900).
