# TrueCharts chart: hassconfigurator

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hassconfigurator/values.yaml (fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hassconfigurator/Chart.yaml (fetched 2026-11-26)

## What it is
- Chart name `hassconfigurator`, chart version `11.0.0`, `appVersion: "x86_64"`.
- Description: "Home Assistant online configurator Chart from https://github.com/danielperna84/hass-configurator".
- Chart sources: upstream app repo, the chart path in truecharts, and the causticlab Docker Hub page.
- Dependency: `common` `32.8.5` from `oci://oci.trueforge.org/truecharts`.

## Runtime / image (as used by the chart)
- Repository: `docker.io/causticlab/hass-configurator-docker`
- Tag: `x86_64@sha256:45a5a0527ca10da5744bbcf3a7909a0b77ae583e97fe0d28d0e5a8d50aa37689`
- Pull policy: `IfNotPresent`
- Note: the draft's container line says `:x86_64`; the chart pins the tag plus a digest. The image is the upstream causticlab build (Python 3.9 alpine, see the causticlab summary), not a ContainerForge build.

## Ports
- Service `main`: port `3218`, protocol `tcp`, targetPort `3218`.

## Volumes/paths and persistent data
- `config`: enabled, mountPath `/config` (no type/size/name set).
- `hass-config`: enabled, mountPath `/hass-config` (no type/size/name set). This is the Home Assistant config directory the editor works on.
- No hostPath entries.

## User/UID & permissions
- Container securityContext: `runAsUser: 0`, `runAsGroup: 0` (root). The ContainerForge build should run as `apps` instead, see the README.
- `readOnlyRootFilesystem: false`.
- `privileged` not set (common default).

## Env vars
- None set in values.yaml.

## Healthcheck/readiness
- No probes defined in values.yaml.

## Gotchas
- Chart is root and writable-rootfs; the draft's security expectations match (non-root possible, read-only no).
- Chart values do not contradict plan.md: image family, port 3218, `/config` and `/hass-config` mounts all match.
