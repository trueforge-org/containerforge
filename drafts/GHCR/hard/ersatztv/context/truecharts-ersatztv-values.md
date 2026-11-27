# TrueCharts ersatztv values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ersatztv/values.yaml (fetched 2026-11-27)

## Images
| Key | Repository | Tag |
| --- | --- | --- |
| image (main) | ghcr.io/ersatztv/ersatztv | v26.3.0@sha256:7c402e5f348184359e0951b44d55fb6db3df671fa77fc91dcbd609034d28778b |
| nvidiaImage | ghcr.io/ersatztv/ersatztv | v25.2.0-nvidia@sha256:cc6d6c8e51c457a08ed48e08e43f3406c48837473a9d580fea6d3831439b4f98 (pullPolicy Always) |
| vaapiImage | ghcr.io/ersatztv/ersatztv | v25.2.0-vaapi@sha256:71f925801b798e01833548d467a1d1f67731fae522e6b29a7e861554e205c594 (pullPolicy Always) |

## Ports
- service.main.ports.main: port 10607, targetPort 8409, protocol http

## Env (set by chart)
None set in values (only probes and images).

## Persistence
| Name | mountPath |
| --- | --- |
| config | /root/.local/share/ersatztv |
| varrun | (enabled, no mountPath set) |

## Probes
- liveness, readiness, startup: type http (no path set; chart default)

## Security context (chart)
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Gotchas
- Chart container listens on 8409 (targetPort), service exposes 10607.
- Chart's data path `/root/.local/share/ersatztv` is not what the upstream Dockerfile sets (`ETV_CONFIG_FOLDER=/config`).
- Chart's nvidia/vaapi image tags are v25.2.0, older than the main tag v26.3.0.
