# static-web-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## How to read the tables

- **Chart / Role**: the TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).
- **Container**: the image and tag the chart uses today.
- **Dockerfile**: the file that builds that image, traced from image labels and upstream repos. `-` means no public Dockerfile could be found.
- **Application source**: the application's own source repository or project page.
- **Application binary**: where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package), or `-` when there is none. It never points at a container image.
- **Difficulty**: `easy` (prebuilt binary, close sibling or steamcmd game server), `medium` (a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build), `hard` (several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only), `very-hard` (closed source with no redistributable artifact, or kernel/host-level tools).
- **amd64 / arm64** (one of `yes`, `compile`, `no`): how we get the application for that architecture.
  - `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
  - `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.
  - `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.
  - A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.
- **copy-from amd64 / copy-from arm64**: a separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us), or `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu. A path in backticks is where the binary sits inside the image. `no*` means the registry could not be queried, so the architecture is unconfirmed.
- **Dependency containers** (main row only): other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars). ✅ means ContainerForge already has an app for it, ❌ means it is missing too.

| Chart | Role | Container | Dockerfile | Application source | Application binary | Difficulty | Reason | amd64 | arm64 | copy-from amd64 | copy-from arm64 | Dependency containers |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| static-web-server | main | `ghcr.io/static-web-server/static-web-server:2.44.3` | [Dockerfile](https://github.com/static-web-server/static-web-server/blob/501cb7fcb6a01a4e73e6d5f541559e3334c39976/docker/scratch/Dockerfile) | [source](https://github.com/static-web-server/static-web-server) | [amd64](https://github.com/static-web-server/static-web-server/releases/download/v2.44.3/static-web-server-v2.44.3-x86_64-unknown-illumos.tar.gz) · [arm64](https://github.com/static-web-server/static-web-server/releases/download/v2.44.3/static-web-server-v2.44.3-aarch64-unknown-linux-gnu-fips.tar.gz) | easy | static-web-server is a Rust binary released as prebuilt linux gnu tarballs for amd64 and arm64. It is one process that serves files on an unprivileged port, so it drops onto containerforge-ubuntu with no compile. The rootless setup is simple. | yes | yes | [ghcr.io/static-web-server/static-web-server:2.44.3](https://ghcr.io/static-web-server/static-web-server) | [ghcr.io/static-web-server/static-web-server:2.44.3](https://ghcr.io/static-web-server/static-web-server) | none |
