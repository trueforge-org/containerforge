# TrueCharts chart: linkwallet

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/linkwallet (read via raw files)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/linkwallet/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/linkwallet/values.yaml
- Fetched 2026-11-26

## What it is
Chart `linkwallet` version `11.0.0`, `appVersion: 0.1.1`. Description: "A self-hosted bookmark database with full-text page content search." Category bookmarks. Depends on `common` `32.8.5`. Kubernetes `>=1.33.0-0`.

## Container
- `docker.io/tardisx/linkwallet`, tag `v0.1.1@sha256:5828c5f14b3dfbabbe9e194ffde3901f04d32c1206a4c84343660809e1aedc80`, pullPolicy `IfNotPresent`.
- Container `main` args: `-db-path /data/linkwallet.db`.

## Persistence
- `data` enabled, mountPath `/data`.

## Service / ports
- Service `main`, port `main`: port `10353`, protocol http, targetPort `8080`.

## Not present
securityContext, podSecurityContext, env, probes.

## Gotchas
- Chart stores the DB under `/data`; plan uses `/config` with `DB_PATH` override (plan section 9). Design difference.
- Chart has no securityContext, so runs with the image default (root). Plan targets UID 568 read-only.
