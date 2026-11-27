# truecharts troddit (chart version 11.0.0, appVersion latest)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/troddit/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/troddit/Chart.yaml
- Fetched 2026-11-27

## What it is
- `name: troddit`, `appVersion: latest`, `version: 11.0.0`, `type: application`
- Description: "A web client for Reddit"

## Image (values.yaml)
- repository: `docker.io/bsyed/troddit`
- tag: `latest@sha256:696350e536fabf1f28ac5baeffee4ca8c33fae9b91907a4ceb51552e51c27fea`
- pullPolicy: IfNotPresent

## Ports
| name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 3000 | 3000 | tcp |

## Persistence
- `persistence: {}` (none set).

## Env (workload.main container `main`)
| key | value |
| --- | --- |
| CLIENT_ID | "" |
| CLIENT_SECRET | secretKeyRef `env-secrets` / `CLIENT_SECRET` |
| NEXTAUTH_SECRET | secretKeyRef `env-secrets` / `NEXTAUTH_SECRET` |
| NEXTAUTH_URL | "" |
| REDDIT_REDIRECT | "" |

Secret `env-secrets` (enabled): CLIENT_SECRET "", NEXTAUTH_SECRET "".

## Security context
- readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0 (no runAsNonRoot set)

## Probes
- None set.

## Gotchas
- Chart pins `latest` by digest; no version pin.
- Env names are NextAuth/Reddit OAuth settings (values empty by default).
