# TrueCharts: mailpile (stable)

Source URL(s), fetched 2026-11-27:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mailpile/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mailpile/Chart.yaml

## What it is
- Chart `mailpile`, chart version 11.0.0, appVersion `latest`, type application, not deprecated
- Description: chart for Mailpile, a browser-driven email client for desktop/laptop aimed at private, secure email.
- Keywords: mailpile, Productivity, Network-Web, Network-Messenger
- Category: Productivity; train: stable
- Dependency: `common` 32.8.5 from oci://oci.trueforge.org/truecharts
- kubeVersion >=1.33.0-0; min helm 3.14, max helm 4.1; max kubernetes 1.35.0
- Sources listed: truecharts chart tree, hub.docker.com/r/rroemhild/mailpile, https://www.mailpile.is/
- Artifacthub support link YAML is malformed (url key at name indent).

## Image (values.yaml)
- Repository: `docker.io/rroemhild/mailpile`
- Tag: `latest`
- Digest: `sha256:5b58d53b2f11ba6ce360006ca1f6459970b3fba8bafdeafafbf1af1d14c58172`
- pullPolicy: IfNotPresent

## Ports (values.yaml)
| Name | Port | Protocol | targetPort |
| --- | --- | --- | --- |
| main (service main) | 33411 | tcp | 33411 |

## Env vars (values.yaml)
- None specified.

## Volumes (values.yaml)
| Key | Enabled | Mount path |
| --- | --- | --- |
| path1 | true | `/root/.local/share/Mailpile` |
| path2 | true | `/root/.gnupg` |

## Probes
- None specified.

## securityContext (container, values.yaml)
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false, fsGroup not specified.

## Command / args overrides
- None.

## Gotchas
- Chart pins `latest` with a digest. Upstream image on Docker Hub is archived (see dockerhub-mailpile.md), so tag behaviour cannot be expected to change.
- Chart mounts state under /root (root home), which is incompatible with a non-root app user; this is a TrueCharts default to be re-mapped in the container, not an upstream requirement.
