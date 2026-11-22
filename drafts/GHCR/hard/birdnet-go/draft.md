# birdnet-go

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
| birdnet-go | main | `ghcr.io/tphakala/birdnet-go:20261031` | [Dockerfile](https://github.com/tphakala/birdnet-go/blob/bc1e0de67d9a2292b4742a79f868a7720f8e6a12/Dockerfile) | [source](https://github.com/tphakala/birdnet-go) | [amd64](https://github.com/tphakala/birdnet-go/releases/download/20261031/birdnet-go-linux-amd64-20261031.tar.gz) · [arm64](https://github.com/tphakala/birdnet-go/releases/download/20261031/birdnet-go-linux-arm64-20261031.tar.gz) | hard | Go binary with TFLite models that needs a live audio capture device (ALSA or USB microphone), so hardware access makes it hard even though the release tarballs exist. Upstream ships a linux-amd64 and linux-arm64 tarball, so packaging is simple and runtime access is the blocker. | yes | yes | [ghcr.io/tphakala/birdnet-go:20261031](https://ghcr.io/tphakala/birdnet-go) | [ghcr.io/tphakala/birdnet-go:20261031](https://ghcr.io/tphakala/birdnet-go) | none |
