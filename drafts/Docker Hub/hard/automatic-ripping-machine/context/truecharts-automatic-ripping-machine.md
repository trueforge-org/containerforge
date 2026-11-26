# TrueCharts chart: automatic-ripping-machine

**Source URL(s) + fetch date:** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/automatic-ripping-machine/values.yaml (chart page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/automatic-ripping-machine) · fetched 2026-11-26

## Container image
- repository `docker.io/automaticrippingmachine/automatic-ripping-machine`
- tag `2.25.0@sha256:97dfbe7b8d2e5ed0493fbe595c2178cd6abaa5e16ed41d43eb591bd1b663b553`
- pullPolicy `IfNotPresent`

## Ports
Service main: protocol http, targetPort `8080`, port `10683`.

## Env vars
- `ARM_UID` = `{{ .Values.securityContext.container.PUID }}`
- `ARM_GID` = `{{ .Values.securityContext.pod.fsGroup }}`

## User/UID & permissions
Container: `runAsUser 0`, `runAsGroup 0`, `runAsNonRoot false`, `readOnlyRootFilesystem false`, `allowPrivilegeEscalation true`. `privileged` and `capabilities` not set.
Init container `arm-perms` (type install, `/bin/sh -c`) runs `chown` to `PUID:fsGroup` on `/home/arm` and `/etc/arm/config`.

## Volumes/paths
- `config` mounted at `/etc/arm/config`.
- `arm` mounted at `/home/arm`.

## Devices / hostPath
None specified in chart (optical drives `/dev/srN` are not mapped by the chart values).

## Healthcheck/readiness
No probes specified.

## Gotchas
- Chart pins `2.25.0`, so plan.md's `2.24.4` was stale; plan corrected.
- Chart does not map `/dev/srN` devices; the port-side design must address device passthrough.

## Contradictions with plan.md
- plan.md Version `2.24.4` contradicts the chart tag `2.25.0`. Corrected in plan.md.
