# TrueCharts spegel values.yaml
Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/spegel/values.yaml (fetched 2026-11-27)

## Image
- repository `ghcr.io/spegel-org/spegel`, tag `v0.8.2@sha256:b9897d9fca912fb667a794be7cb458b6002999c87e6c08db11c869fd685975f6`, pullPolicy IfNotPresent

## Security
- container runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false; pod fsGroup 0

## Ports
| service | port | targetPort | hostPort | nodePort | notes |
| --- | --- | --- | --- | --- | --- |
| main | 5000 | 5000 | 30020 | 30021 | registry mirror |
| router | 5001 | 5001 | - | - | headless (clusterIP None), publishNotReadyAddresses |
| metrics | 9090 | 9090 | - | - | ServiceMonitor endpoint `metrics` |

## Workload
- type DaemonSet
- initContainer `configuration` (type init), env NODE_IP = fieldRef status.hostIP
- main container env NODE_IP = fieldRef status.hostIP
- probes: liveness /livez, readiness /readyz, startup /readyz

## Pod options
- automountServiceAccountToken true, priorityClassName system-node-critical
- nodeSelector kubernetes.io/arch ""
- tolerations: CriticalAddonsOnly Exists; effect NoExecute Exists; effect NoSchedule Exists

## Persistence (hostPath)
| name | hostPath | mountPath | type | notes |
| --- | --- | --- | --- | --- |
| containerd-sock | spegel.containerdSock (/run/containerd/containerd.sock) | same | Socket | |
| containerd-content | spegel.containerdContentPath (/var/lib/containerd/io.containerd.content.v1.content) | same | Directory | readOnly |
| containerd-config | spegel.containerdRegistryConfigPath (/etc/cri/conf.d/hosts) | same, on initContainer `configuration` | DirectoryOrCreate | |

## Spegel settings (values `spegel`)
- logLevel "INFO" (DEBUG|INFO|WARN|ERROR)
- mirroredRegistries: cgr.dev, docker.io, ghcr.io, quay.io, mcr.microsoft.com, public.ecr.aws, gcr.io, registry.k8s.io, k8s.gcr.io, oci.trueforge.org, factory.talos.dev (all https://)
- additionalMirrorTargets []
- mirrorResolveRetries 3, mirrorResolveTimeout "20ms"
- containerdSock /run/containerd/containerd.sock
- containerdNamespace "k8s.io"
- containerdRegistryConfigPath /etc/cri/conf.d/hosts
- containerdContentPath /var/lib/containerd/io.containerd.content.v1.content
- containerdMirrorAdd true, resolveTags true, prependExisting true

## Other
- configmap `dashboard` (grafana_dashboard label "1") with spegel.json from dashboard.json
- serviceAccount main enabled, primary
- metrics.main ServiceMonitor enabled
