# TrueCharts volsync (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/volsync/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- VolSync: asynchronous PV replication/backup operator. Chart 6.0.0, appVersion 0.16.0. Depends on common 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.
- Chart sources: github backube/helm-charts, backube/volsync, quay.io/backube/volsync, volsync.readthedocs.io.

## Image
- repository: quay.io/backube/volsync ; tag: 0.16.0@sha256:0d03a6aad57569eba2c0eaa0848cf4a908d9744b372ff2224bb291a320f36d76

## Command / args (main)
- command: /manager
- --health-probe-bind-address=:8081 ; --metrics-bind-address=:8443 ; --metrics-secure=true ; --metrics-require-rbac=false ; --leader-elect
- Mover images all = same image: --rclone-container-image, --restic-container-image, --rsync-container-image, --rsync-tls-container-image, --syncthing-container-image
- --scc-name=volsync-privileged-mover

## Ports
| Name | Port | Proto | Notes |
| --- | --- | --- | --- |
| main | 8081 | http | health probes (/healthz, /readyz) |
| metrics | 8443 | https | ClusterIP service, metrics path /metrics |

## Probes
- liveness /healthz ; readiness /readyz ; startup /readyz

## Other
- manageCRDs true, manageVSCCRD true.
- ServiceMonitor on metrics port, scheme https, insecureSkipVerify true.
- RBAC: namespaced role (configmaps, leases, events); cluster role (tokenreviews, subjectaccessreviews, deployments, jobs, PVCs, PVs, pods, secrets, services, serviceaccounts, etc.), allServiceAccounts true.
- automountServiceAccountToken true.
