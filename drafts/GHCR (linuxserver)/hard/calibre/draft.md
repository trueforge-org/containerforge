# calibre

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
| calibre | main | `ghcr.io/linuxserver/calibre:9.18.0` | [Dockerfile](https://github.com/linuxserver/docker-calibre/blob/8aa349b17edf2d4bed988982d71803684399f01a/Dockerfile) | [source](https://github.com/kovidgoyal/calibre) | [amd64](https://github.com/kovidgoyal/calibre/releases/download/v9.18.0/calibre-9.18.0-x86_64.txz) · [arm64](https://github.com/kovidgoyal/calibre/releases/download/v9.18.0/calibre-9.18.0-arm64.txz) | hard | Calibre e-book manager (Qt/Python) delivered by linuxserver as a selkies browser desktop. Upstream now ships prebuilt x86_64 and arm64 tarballs, but it needs a desktop/VNC layer (kasmvnc, xvfb exist), root-style GUI base rework and a large Qt stack, so hard. | yes | yes | [ghcr.io/linuxserver/calibre:9.18.0](https://ghcr.io/linuxserver/calibre) | [ghcr.io/linuxserver/calibre:9.18.0](https://ghcr.io/linuxserver/calibre) | none |
