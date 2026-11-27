# TrueCharts firefox-syncserver Chart.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/firefox-syncserver/Chart.yaml (fetched 2026-11-27)

## Metadata
- name: firefox-syncserver
- chart version: 23.0.0
- appVersion: 1.8.0
- type: application, deprecated: false
- kubeVersion: `>=1.33.0-0`
- description: This is an all-in-one package for running a self-hosted Firefox Sync server.
- keywords: server, sync, syncserver, firefox
- home: https://truecharts.org/charts/stable/firefox-syncserver

## Dependencies
- common 32.8.5 from `oci://oci.trueforge.org/truecharts`
- postgresql (chart dependency, enabled, `postgresqlUsername` and `postgresqlDatabase` = firefox-syncserver)

## Sources (listed by chart)
- https://ghcr.io/crazy-max/firefox-syncserver
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/firefox-syncserver
- https://moz-services-docs.readthedocs.io/en/latest/howtos/run-sync-1.5.html

## Annotations
- trueforge.org/category: media
- min_helm_version "3.14", max_helm_version "4.1", max_kubernetes_version 1.35.0
- train: stable
