# authentik

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: authentik
- **Rows**: 5
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/authentik
- **Source repository**: https://github.com/goauthentik/authentik
- **Source repository**: https://github.com/kiwigrid/k8s-sidecar
- **Source repository**: https://github.com/maxmind/geoipupdate
- **Documentation**: https://docs.goauthentik.io/

## Potentially relevant resources

- **Container image**: https://ghcr.io/goauthentik/ldap
- **Container image**: https://ghcr.io/goauthentik/proxy
- **Container image**: https://ghcr.io/goauthentik/radius
- **Container image**: https://ghcr.io/goauthentik/server
- **Container image**: https://ghcr.io/kiwigrid/k8s-sidecar
- **Container image**: https://ghcr.io/maxmind/geoipupdate
- **Website**: https://goauthentik.io/docs

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Guess: the draft row has no image or binary details, so ubuntu is a default.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- Row 1: **Chart**: authentik
- Row 1: **Role**: sidecar (ldapImage)
- Row 2: **Chart**: authentik
- Row 2: **Role**: sidecar (proxyImage)
- Row 3: **Chart**: authentik
- Row 3: **Role**: sidecar (radiusImage)
- Row 4: **Chart**: authentik
- Row 4: **Role**: sidecar (sidecarImage)
- Row 5: **Chart**: authentik
- Row 5: **Role**: sidecar (geoipImage)

### Container

The image and tag the chart uses today.

- Row 1: **Container**: `ghcr.io/goauthentik/ldap:2026.8.6`
- Row 2: **Container**: `ghcr.io/goauthentik/proxy:2026.8.6`
- Row 3: **Container**: `ghcr.io/goauthentik/radius:2026.8.6`
- Row 4: **Container**: `ghcr.io/kiwigrid/k8s-sidecar:2.14.3`
- Row 5: **Container**: `ghcr.io/maxmind/geoipupdate:v8.0.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- Row 1: **Dockerfile**: [Dockerfile](https://github.com/goauthentik/authentik/blob/98ec4a7684fcb0cccfe78888a12df1df1ad938be/lifecycle/container/ldap.Dockerfile)
- Row 2: **Dockerfile**: [Dockerfile](https://github.com/goauthentik/authentik/blob/98ec4a7684fcb0cccfe78888a12df1df1ad938be/lifecycle/container/proxy.Dockerfile)
- Row 3: **Dockerfile**: [Dockerfile](https://github.com/goauthentik/authentik/blob/98ec4a7684fcb0cccfe78888a12df1df1ad938be/lifecycle/container/radius.Dockerfile)
- Row 4: **Dockerfile**: [Dockerfile](https://github.com/kiwigrid/k8s-sidecar/blob/2.14.3/Dockerfile)
- Row 5: **Dockerfile**: [Dockerfile](https://github.com/maxmind/geoipupdate/blob/v8.0.0/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- Row 1: **Application source**: [source](https://github.com/goauthentik/authentik)
- Row 2: **Application source**: [source](https://github.com/goauthentik/authentik)
- Row 3: **Application source**: [source](https://github.com/goauthentik/authentik)
- Row 4: **Application source**: [source](https://github.com/kiwigrid/k8s-sidecar)
- Row 5: **Application source**: [source](https://github.com/maxmind/geoipupdate)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- Row 1: **Application binary**: [amd64](https://github.com/goauthentik/authentik/releases/download/version%2F2026.8.6/authentik-outpost-ldap_linux_amd64) · [arm64](https://github.com/goauthentik/authentik/releases/download/version%2F2026.8.6/authentik-outpost-ldap_linux_arm64)
- Row 2: **Application binary**: [amd64](https://github.com/goauthentik/authentik/releases/download/version%2F2026.8.6/authentik-outpost-proxy-x86_64-unknown-linux-gnu) · [arm64](https://github.com/goauthentik/authentik/releases/download/version%2F2026.8.6/authentik-outpost-proxy-aarch64-unknown-linux-gnu)
- Row 3: **Application binary**: [amd64](https://github.com/goauthentik/authentik/releases/download/version%2F2026.8.6/authentik-outpost-radius_linux_amd64) · [arm64](https://github.com/goauthentik/authentik/releases/download/version%2F2026.8.6/authentik-outpost-radius_linux_arm64)
- Row 4: **Application binary**: [binary](https://github.com/kiwigrid/k8s-sidecar/archive/refs/tags/2.14.3.tar.gz)
- Row 5: **Application binary**: [amd64](https://github.com/maxmind/geoipupdate/releases/download/v8.0.0/geoipupdate_8.0.0_linux_amd64.tar.gz) · [arm64](https://github.com/maxmind/geoipupdate/releases/download/v8.0.0/geoipupdate_8.0.0_linux_arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- Row 1: **Difficulty**: easy
- Row 2: **Difficulty**: easy
- Row 3: **Difficulty**: easy
- Row 4: **Difficulty**: easy
- Row 5: **Difficulty**: easy

### Reason

- Row 1: **Reason**: Static Go outpost binary; fetch the release asset per arch (or reuse the image binary) onto containerforge-ubuntu. Stateless, rootless, no writable paths; the FIPS debian base is not required.
- Row 2: **Reason**: Outpost proxy is now a prebuilt glibc binary (Rust-based per trace) distributed as release assets; drop it into containerforge-ubuntu. Stateless and rootless; may need ca-certificates and no extra services.
- Row 3: **Reason**: Static Go outpost binary; download the release asset per arch onto containerforge-ubuntu. Stateless, rootless and read-only friendly, listens on UDP 1812.
- Row 4: **Reason**: Python script app; ContainerForge already has a k8s-sidecar app, so reuse or update that sibling (pip install into a venv on the python base). Alpine is only the upstream base, nothing musl-specific.
- Row 5: **Reason**: Static Go CLI with a small entrypoint script (needs jq, cron-like loop). Download the release tarball per arch onto containerforge-ubuntu; config via env, writes the database to a writable /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- Row 1: **amd64**: yes
- Row 1: **arm64**: yes
- Row 2: **amd64**: yes
- Row 2: **arm64**: yes
- Row 3: **amd64**: yes
- Row 3: **arm64**: yes
- Row 4: **amd64**: yes
- Row 4: **arm64**: yes
- Row 5: **amd64**: yes
- Row 5: **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- Row 1: **copy-from amd64**: [ghcr.io/goauthentik/ldap:2026.8.6](https://ghcr.io/goauthentik/ldap)
- Row 1: **copy-from arm64**: [ghcr.io/goauthentik/ldap:2026.8.6](https://ghcr.io/goauthentik/ldap)
- Row 2: **copy-from amd64**: [ghcr.io/goauthentik/proxy:2026.8.6](https://ghcr.io/goauthentik/proxy)
- Row 2: **copy-from arm64**: [ghcr.io/goauthentik/proxy:2026.8.6](https://ghcr.io/goauthentik/proxy)
- Row 3: **copy-from amd64**: [ghcr.io/goauthentik/radius:2026.8.6](https://ghcr.io/goauthentik/radius)
- Row 3: **copy-from arm64**: [ghcr.io/goauthentik/radius:2026.8.6](https://ghcr.io/goauthentik/radius)
- Row 4: **copy-from amd64**: no
- Row 4: **copy-from arm64**: no
- Row 5: **copy-from amd64**: no
- Row 5: **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

- Row 1: **Dependency containers**: -
- Row 2: **Dependency containers**: -
- Row 3: **Dependency containers**: -
- Row 4: **Dependency containers**: -
- Row 5: **Dependency containers**: -
