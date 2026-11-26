# k8snetworkplumbingwg/multus-cni (Multus CNI, the chart's real workload)

**Source URL(s) + fetch date:** https://github.com/k8snetworkplumbingwg/multus-cni ; https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/README.md · fetched 2026-11-26

## What it is
Kubernetes CNI meta-plugin that lets a pod call multiple CNI plugins so it can have several network interfaces (default `eth0` plus extra attachments). Follows the Kubernetes Network CRD de-facto standard (Network Plumbing Working Group).

## Install methods (upstream)
- Requires a default cluster CNI already installed.
- Thick plugin (recommended, Multus 4.0+): DaemonSet `deployments/multus-daemonset-thick.yml`. Two binaries: `multus-daemon` (node agent, metrics) and `multus-shim` CNI plugin.
- Thin plugin: `deployments/multus-daemonset.yml` (older, lower resource use).
- Other: release binaries, GHCR image, build from source.

## Runtime / privileges (from TrueCharts values, not upstream README)
Chart runs `main` privileged with hostNetwork, hostPID and hostPath mounts (see truecharts-multus-cni.md). Upstream README does not state required privileges.

## Not stated on the README
Install paths (/opt/cni/bin per chart), config file location/format, CLI flags, env vars, ports, supported architectures, release numbers (beyond 4.0 thick).

## Version/release info
Chart uses `ghcr.io/k8snetworkplumbingwg/multus-cni:v4.3.2-thick`.

## Gotchas
- This is a Kubernetes node component, not a standalone container app. Plan.md scopes ContainerForge to the crane sidecar only (Multus daemon not built here). Consistent with the draft's naming note.
