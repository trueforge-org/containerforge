# BeryJu/gravity: Dockerfile + Makefile + go.mod (commit 38c79473)

Source URL(s): https://raw.githubusercontent.com/BeryJu/gravity/38c7947343d673dbe379ba3cc412fabf773ff7d9/Dockerfile (fetched 2026-11-27; blob/ variant same), .../Makefile, .../go.mod (fetched). LICENSE HTTP 200 (not read). Docs: https://gravity.beryju.io/docs (fetched, nav/welcome only). /docs/installation guessed path returned 404.

## Build (4 stages)
1. web-builder: FROM --platform=$BUILDPLATFORM docker.io/library/node:26; NODE_ENV=production; `make web-install` (npm ci in web/), `make web-build` (npm run build) -> web/dist.
2. downloader: FROM docker.io/library/ubuntu:26.04; apt install make curl ca-certificates tshark; `make internal/resources/macoui internal/resources/blocky internal/resources/tftp`.
3. builder: FROM docker.io/library/golang:1.27; GIT_BUILD_HASH, TARGETARCH, GRAVITY_BUILD_ARGS args; CGO_ENABLED=0, GOOS=linux, GOARCH=$TARGETARCH; `go mod download`; `make ${GRAVITY_BUILD_ARGS} docker-build` -> /workspace/gravity.
4. runtime: FROM docker.io/library/debian:stable-slim; apt install nmap bash-completion bash ca-certificates; mkdir /data; chown 65532:65532 /data; bash completion generated.
- COPY gravity -> /bin/gravity. ENTRYPOINT ["/bin/gravity"], CMD ["server"]. WORKDIR /.

## Makefile details
- VERSION "0.34.0"; ldflags set `beryju.io/gravity/pkg/extconfig.Version` and `.BuildHash`.
- docker-build: `go build ... -o gravity ./cmd/server/main`.
- Resource downloads at build (network needed):
  - macoui: `tshark -G manuf` -> internal/resources/macoui/db.txt
  - blocky lists: adaway.org/hosts.txt, big.oisd.nl/domainswild, StevenBlack hosts, v.firebog.net AdguardDNS and Easylist, adguardteam filter.txt
  - tftp: boot.ipxe.org ipxe.efi and undionly.kpxe; boot.netboot.xyz kpxe/efi images
- Also docker-build-external-dns target builds gravity-external-dns (not used by this image).

## go.mod
- module beryju.io/gravity; go 1.27.3. Deps include github.com/0xERR0R/blocky v0.35.0.

## Runtime deps
- nmap, bash, bash-completion, ca-certificates (Debian stable-slim).

## Entrypoint / CMD
- `/bin/gravity server`.

## User/UID
- No USER set in Dockerfile (runs as root). /data owned by 65532:65532.

## Volumes/paths
- /data (owned 65532). Binary /bin/gravity. Completion /etc/bash_completion.d/gravity.

## Version/asset naming
- Build-arg GIT_BUILD_HASH; version from Makefile VERSION (0.34.0).

## Gotchas
- Build stage uses golang:1.27 while go.mod declares go 1.27.3.
- Build needs many external downloads (blocklists, iPXE, netboot.xyz); offline builds fail.
- Image is not multi-stage-minimal: includes nmap and tshark only in builder/downloader (tshark not in final).
