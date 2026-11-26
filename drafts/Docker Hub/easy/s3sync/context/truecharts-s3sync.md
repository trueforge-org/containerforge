# TrueCharts s3sync chart

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/s3sync (fetched 2026-11-26; directory listing only)

## What it is
TrueCharts Helm chart `s3sync` under `charts/stable/s3sync`.

## Files in the chart directory
templates/, .helmignore, CHANGELOG.md, Chart.yaml, README.md, icon-small.webp, icon.webp, values.schema.json, values.yaml.

## Install
`helm install mychart oci://oci.trueforge.org/truecharts/s3sync` (from README).

## Notes
- Chart README says the chart is not maintained by the upstream project and issues go to TrueCharts.
- Values come from the shared "common" library chart.
- Chart.yaml and values.yaml contents were not visible in the listing fetch, so the draft's values (runAsUser 0, readOnlyRootFilesystem false, `/data/example` mount) are NOT confirmed here. Only the draft states them.
