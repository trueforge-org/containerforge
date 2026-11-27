# TrueCharts chart: anope (fetched 2026-11-27)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/anope/values.yaml , .../Chart.yaml

## What it is
- Chart `anope` version 11.0.0, appVersion `latest`, depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts)
- Description: "Anope is a set of IRC Services designed for flexibility and ease of use."
- Category: Network-Other; train stable; kubeVersion >=1.33.0-0
- Sources listed: https://ghcr.io/ich777/anope , https://thelounge.chat/ (chart metadata, not build source)

## Image (values.yaml)
- repository: `ghcr.io/ich777/anope`
- tag: `latest@sha256:821f20471a7b22595ef2d77ac50eca72d74fa0d8e26d08eee2f8c94d2a328214` (floating tag, digest pinned)
- pullPolicy: IfNotPresent

## Persistence
- `datapath`: enabled, mountPath `/anope`

## Security context
- readOnlyRootFilesystem: false, runAsUser 0, runAsGroup 0 (upstream chart runs as root)

## Env (workload.main container `main`)
| Name | Chart default |
| --- | --- |
| CASEMAP | rfc1459 |
| DATA_PERM | "770" |
| HOST | irc.example.com |
| IP_ADDR | "" |
| IRCD | inspircd3 |
| LOCAL_HOSTNAME | services |
| PASSWORD | secretKeyRef env-secrets/PASSWORD |
| PORT | "7000" |
| SSL | "yes" |

## Ports / service
- service.main enabled: false, port main disabled (no inbound port exposed)

## Probes
- liveness, readiness, startup: all disabled

## Gotchas
- Chart env names differ from the ich777 Dockerfile defaults only where noted (SSL default "yes" in chart vs "no" in Dockerfile)
