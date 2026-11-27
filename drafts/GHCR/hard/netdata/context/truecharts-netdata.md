# TrueCharts chart: netdata

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/netdata/{Chart.yaml,values.yaml} (fetched 2026-11-27)

## What it is
- Chart `netdata` v16.0.0, appVersion 2.13.0, category utilities.
- Depends on `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion >=1.33.0-0; min helm 3.14; max helm 4.1; max k8s 1.35.0.

## Image
- repository: `ghcr.io/netdata/netdata`
- tag: `v2.13.0@sha256:176156c6754770e6157cc87394849a8e3047a13b52f393ff021093866f7f9e5c`
- pullPolicy: IfNotPresent

## Service / ports
- service.main port 19999 -> targetPort 19999 (http).

## Probes (main)
- liveness, readiness, startup: HTTP GET path `/api/v1/info` (port from chart default).

## Env (main container)
| Env | Source |
| --- | --- |
| MY_NODE_NAME | fieldRef spec.nodeName |
| MY_POD_NAMESPACE | fieldRef metadata.namespace |
| MY_POD_NAME | fieldRef metadata.name |
| NETDATA_CLAIM_URL | "" |
| NETDATA_CLAIM_TOKEN | secret env-secrets (empty default) |
| NETDATA_CLAIM_ROOMS | "" |

## Config (configmap `configs`, copied by init container create-config)
| Config key | Mounted at | Copied to (only if missing) |
| --- | --- | --- |
| netdata-conf | /etc/netdata/truecharts-defaults/.netdata.conf | /etc/netdata/netdata.conf |
| go-d-conf | /etc/netdata/truecharts-defaults/.go.d.conf | /etc/netdata/go.d.conf |
| go-d-k8s-state-conf | /etc/netdata/truecharts-defaults/go.d/.k8s_state.conf | /etc/netdata/go.d/k8s_state.conf |

- netdata.conf defaults: memory mode = dbengine; dbengine multihost disk space = 4096; page cache size = 64.
- go.d: modules k8s_state yes; k8s_state job update_every 1.

## Persistence
| Name | mountPath | Type / source |
| --- | --- | --- |
| config | /etc/netdata | PVC-like (targetSelectAll) |
| lib | /var/lib/netdata | PVC-like |
| cache | /var/cache/netdata | PVC-like |
| passwd | /host/etc/passwd | hostPath /etc/passwd, ro |
| group | /host/etc/group | hostPath /etc/group, ro |
| proc | /host/proc | hostPath /proc, ro |
| dev | /host/dev | hostPath /dev, ro |
| sys | /host/sys | hostPath /sys, ro |
| os | /host/etc/os-release | hostPath /etc/os-release, ro |

## RBAC (primary)
- pods, nodes, nodes/metrics: get, list, watch.
- namespaces: get.
- serviceAccount main enabled, primary; automountServiceAccountToken true.

## Security
- container: readOnlyRootFilesystem false; runAsUser 0; runAsGroup 0; runAsNonRoot false; capabilities add SYS_PTRACE.
- pod: fsGroup 201.

## Gotchas
- Chart requires root and SYS_PTRACE plus host proc/sys/dev mounts; conflicts with ContainerForge rootless/read-only target unless worked around.
- Chart config keys must match netdata's default config file paths above.
