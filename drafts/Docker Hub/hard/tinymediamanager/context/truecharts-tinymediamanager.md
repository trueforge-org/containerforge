# TrueCharts: tinymediamanager chart (values.yaml)

**Source URL(s):** https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tinymediamanager (fetched via https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tinymediamanager/values.yaml)
**Fetched:** 2026-11-26

## Image
- `docker.io/tinymediamanager/tinymediamanager:5.3.5`, pinned by digest beginning `26e80b1b1c52…`, pull policy IfNotPresent.
- Note: the chart pins 5.3.5 (not `latest`), while the Docker Hub `latest` tag is the image checked above.

## Service and ports
- Service `main`, port `main`: port **10179**, target port **4000**.

## Env
- `PASSWORD` read from secret `env-secrets` key `PASSWORD`. Secret enabled, default value empty (needs a value).

## Persistence
| Volume | Enabled | Mount path |
| --- | --- | --- |
| data | true | `/data` |
| movies | true | `/media/movies` |
| tvshows | true | `/media/tvshows` |

No sizes; no readOnly settings.

## Security context
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false. Container runs as root with writable rootfs.

## Probes
None defined.

## Other
- Schema reference `./values.schema.json` (local).
- Common library-style layout (`workload.main.podSpec.containers.main`, `persistence`, `secret`).
- Chart target port is 4000 (noVNC). The plan uses ContainerForge kasmvnc ports 3000/3001 instead.
