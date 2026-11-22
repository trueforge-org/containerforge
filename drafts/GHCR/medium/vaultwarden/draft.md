# vaultwarden

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
| vaultwarden | main | `ghcr.io/dani-garcia/vaultwarden:1.37.5` | [Dockerfile](https://github.com/dani-garcia/vaultwarden/blob/6ed6921cc2b0e03b4d74189574d2a5e71c512e97/docker/Dockerfile.debian) | [source](https://github.com/dani-garcia/vaultwarden) | - | medium | Rust server compiled with cargo in a rust stage, with the web vault copied from upstream. No release binary exists, so both arches need a Rust build. The runtime is simple and rootless-friendly, and the beta sidecar uses the same build. | compile | compile | [ghcr.io/dani-garcia/vaultwarden:1.37.5](https://ghcr.io/dani-garcia/vaultwarden) | [ghcr.io/dani-garcia/vaultwarden:1.37.5](https://ghcr.io/dani-garcia/vaultwarden) | postgresql (CNPG) ✅, vaultwarden (betaImage) ❌ |
| vaultwarden | sidecar (betaImage) | `ghcr.io/timshel/vaultwarden:1.30.5-9` | [Dockerfile](https://github.com/timshel/vaultwarden/blob/39febc27950fece51ded8b85c2d38838fe08237c/docker/Dockerfile.debian) | [source](https://github.com/timshel/vaultwarden) | - | medium | Fork of Vaultwarden with SSO, built from Rust source (cargo) plus a web-vault bundle; no release assets, so build in a rust stage on glibc Ubuntu with openssl and sqlite/mysql/pg libs and copy to /app. Long compile; data to /config. | compile | compile | [ghcr.io/timshel/vaultwarden:1.30.5-9](https://ghcr.io/timshel/vaultwarden) | [ghcr.io/timshel/vaultwarden:1.30.5-9](https://ghcr.io/timshel/vaultwarden) | - |
