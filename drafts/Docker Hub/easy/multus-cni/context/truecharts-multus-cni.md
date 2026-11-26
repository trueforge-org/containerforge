# TrueCharts chart: multus-cni

**Source URL(s) + fetch date:** https://github.com/trueforge-org/truecharts/tree/master/charts/stable/multus-cni (values read from https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/multus-cni/values.yaml) · fetched 2026-11-26

## What it is
TrueCharts Helm chart for Multus CNI on Kubernetes. Several containers; the only one relevant to ContainerForge plan is `craneImage`.

## Images
| Key | Repository | Tag |
| --- | --- | --- |
| image (main, multus-plugin-installer) | ghcr.io/k8snetworkplumbingwg/multus-cni | v4.3.2-thick@sha256:109b885d... |
| craneImage (talos-plugin-installer) | docker.io/alpine/crane | 0.22.1@sha256:ab2ff377... |
| talosCniImage (pulled by crane) | ghcr.io/siderolabs/cni | v1.14.0@sha256:71732825... |

pullPolicy IfNotPresent. `cleanup` and `dhcp-daemon` reference `ubuntuImage`, not defined in this file.

## Crane usage (the part plan.md builds)
- `talos-plugin-installer` (init): `sh -c` script; `crane export` on `talosCniImage` into `cni.tar`, extracts `opt/cni/bin`, copies enabled CNIs (macvlan, ipvlan by default) into the `cnibin` mount.
- Security: privileged true, runAsUser 0, runAsGroup 0, drops ALL capabilities. Enabled only when Talos is enabled and CNIs to install are set.

## Security of other containers
- `multus-plugin-installer`, `cleanup`, `dhcp-daemon`, `main`: privileged true, runAsUser 0, runAsGroup 0.
- Pod: hostNetwork true, hostPID true, DaemonSet, priorityClass system-node-critical, toleration `operator: Exists`.

## Persistence (hostPath unless noted)
- cnibin `/opt/cni/bin` (Bidirectional propagation), cniconf `/etc/cni/net.d`, cnimultusdata `/var/lib/cni/multus`, hostroot `/`, hostrun `/run`, hostrunnetns `/var/run/netns`, hostrunk8scnicncfio `/run/k8s.cni.cncf.io`, hostvarlibkubelet `/var/lib/kubelet`, daemonconfig ConfigMap mounted read-only at `/multus.d/daemon-config.json`.

## Ports
- `main` service port 8080 (http), clusterIP None, when metrics enabled. Metrics servicemonitor path `/metrics`.

## Env vars
`MULTUS_NODE_NAME` from `spec.nodeName` (main).

## Command overrides
- multus-plugin-installer: `/usr/src/multus-cni/bin/install_multus -d <cnibin> -t thick`.
- main: args `--config <daemonconfig path>`.

## Gotchas
- The chart's crane image is consumed only as an init sidecar that needs write access to hostPath mounts; plan.md's non-privileged, read-only-rootfs crane image is about the crane image itself, not the chart's privileged installer (plan.md reconciliation is consistent with this).
- Chart's craneImage (0.22.1) matches plan.md version.
