# TrueCharts lingva

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/lingva/values.yaml (2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/lingva/Chart.yaml (2026-11-26)

## What it is
- Chart `appVersion: latest`, `kubeVersion: '>=1.33.0-0'`, category `Productivity`, train `stable`.
- Description: "Alternative front-end for Google Translate, serving as a Free and Open Source translator with over a hundred languages available".
- Library dep: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).

## Image
- `docker.io/thedaviddelta/lingva-translate`, tag `latest@sha256:7c9837562e49923ccadfe0e2a017fa3419a1d2878efdd33b2ef754316b6d0ae7`, `pullPolicy: IfNotPresent`.

## Env vars
| Name | Value |
| --- | --- |
| site_domain (container `main`, workload.podSpec env) | "" |

- Lowercase `site_domain` is passed to upstream CMD, which maps it to `NEXT_PUBLIC_SITE_DOMAIN` (see github-lingva-dockerfile.md).
- Chart does not set force_default_theme, default_source_lang, default_target_lang.

## Ports
- service `main` / port `main`: 3000, protocol tcp, targetPort 3000.

## Probes
- None set in chart values.

## Volumes/paths
- `persistence: {}` (none).

## User/UID
- `securityContext.container`: `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false` (chart override; upstream image runs as `nextjs` UID 1001).

## Gotchas
- Chart pins the single Docker Hub `latest` tag (last updated 2022-10-21). See dockerhub-lingva.md.
