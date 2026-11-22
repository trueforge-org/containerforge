# tt-rss

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
| tt-rss | main | `ghcr.io/tt-rss/tt-rss:latest` | [Dockerfile](https://github.com/tt-rss/tt-rss/blob/03628f0aa3c4a86e960ddd61b5ba372cd3a27b50/.docker/app/Dockerfile) | [source](https://github.com/tt-rss/tt-rss) | [binary](https://github.com/tt-rss/tt-rss/archive/refs/heads/master.zip) | medium | PHP application with php-fpm and an update daemon, installed via Alpine apk and plugins cloned with git at build time. Port to Ubuntu apt PHP and fold the nginx sidecar onto the nginx sibling; the app itself is pure PHP with no compile step. | yes | yes | no | no | postgresql (CNPG) ✅, tt-rss-web-nginx (nginxImage) ❌ |
| tt-rss | sidecar (nginxImage) | `ghcr.io/tt-rss/tt-rss-web-nginx:latest` | [Dockerfile](https://github.com/tt-rss/tt-rss/blob/d62bcf96d01a7a2e750f6c9581ca462556e57281/.docker/web-nginx/Dockerfile) | [source](https://github.com/tt-rss/tt-rss) | binary: `apt:nginx (tt-rss source: https://gitlab.tt-rss.org/tt-rss/tt-rss)` | medium | Nginx config plus tt-rss PHP static files copied in; reuse the ContainerForge nginx base and fetch the tt-rss source (tarball). Needs nginx temp dirs redirected for rootless/read-only, and it is only the web half of a php-fpm pair. | yes | yes | no | no | - |
