# TrueCharts ctfd Chart.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ctfd/Chart.yaml (fetched 2026-11-27)

## What it is
- name `ctfd`, type `application`, chart version `16.0.0`, appVersion `3.8.9` (CTFd release)
- description: "CTFd is a Capture The Flag framework focusing on ease of use and customizability."
- deprecated: false, kubeVersion `>=1.33.0-0`

## Dependencies
- `common` `32.8.5` from `oci://oci.trueforge.org/truecharts`
- `valkey` is enabled through values (dependencies.valkey.enabled)

## Sources (as listed)
- https://ghcr.io/ctfd/ctfd
- https://github.com/CTFd/CTFd
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ctfd

## Gotchas
- Chart image is GHCR (`ghcr.io/ctfd/ctfd`). No Docker Hub page applies.
