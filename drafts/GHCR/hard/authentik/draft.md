# authentik

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: authentik
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: yes (geoipupdate, ldap, radius, proxy, k8s-sidecar)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/authentik
- **Source repository**: https://github.com/goauthentik/authentik
- **Documentation**: https://docs.goauthentik.io
- **Documentation**: https://docs.goauthentik.io/
- **Website**: https://goauthentik.io/

## Potentially relevant resources

- **Container image**: https://ghcr.io/goauthentik/ldap
- **Container image**: https://ghcr.io/goauthentik/proxy
- **Container image**: https://ghcr.io/goauthentik/radius
- **Container image**: https://ghcr.io/goauthentik/server
- **Container image**: https://ghcr.io/kiwigrid/k8s-sidecar
- **Container image**: https://ghcr.io/maxmind/geoipupdate
- **Website**: https://goauthentik.io/docs

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python Django server is the main runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: libpq5 (inferred)
- python/pip: authentik server deps from pyproject (inferred)
- node/npm: frontend build (inferred)
- other: none

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: authentik
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/goauthentik/server:2026.8.6`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/goauthentik/authentik/blob/98ec4a7684fcb0cccfe78888a12df1df1ad938be/lifecycle/container/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/goauthentik/authentik)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/goauthentik/authentik/releases/download/version%2F2026.8.6/authentik-outpost-ldap_linux_amd64) · [arm64](https://github.com/goauthentik/authentik/releases/download/version%2F2026.8.6/authentik-outpost-ldap_linux_arm64)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Large multi-service stack: Python 3.14 Django server and worker on a FIPS base, plus a Go LDAP service, a Rust proxy and a GeoIP updater, spread over six images. Multiple processes, a built frontend and several sidecars make this a hard port even though the main app is Python.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/goauthentik/server:2026.8.6](https://ghcr.io/goauthentik/server)
- **copy-from arm64**: [ghcr.io/goauthentik/server:2026.8.6](https://ghcr.io/goauthentik/server)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

❌ means it is missing too.

- **Dependency containers**: postgresql ✅, geoipupdate (geoipImage) ❌, ldap (ldapImage) ❌, radius (radiusImage) ❌, proxy (proxyImage) ❌, k8s-sidecar (sidecarImage) ✅
