# TrueCharts tasmocompiler values.yaml
Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tasmocompiler/values.yaml (fetched 2026-11-27)

## Image
- repository `ghcr.io/benzino77/tasmocompiler`, tag `latest@sha256:ffe692fb072d719e730d2284b9b873efde6dcc7294edcc50845eaedfe5721ec3`, pullPolicy IfNotPresent

## Security
- readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0 (image Dockerfile sets USER node; chart overrides to root)

## Ports
- service main: port 14003, protocol http, targetPort 3000

## Env / persistence
- No env or persistence overrides in values.yaml
