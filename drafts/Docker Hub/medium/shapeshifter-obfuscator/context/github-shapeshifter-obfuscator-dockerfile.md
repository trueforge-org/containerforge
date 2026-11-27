# GitHub: juchong/shapeshifter-docker Dockerfile (d2857ae) and OperatorFoundation/shapeshifter-dispatcher

Source URL(s): raw juchong/shapeshifter-docker/d2857ae/Dockerfile; api OperatorFoundation/shapeshifter-dispatcher license and releases/latest (fetched 2026-11-27)

## Upstream dispatcher
- Project: OperatorFoundation/shapeshifter-dispatcher (Go). License: MIT (GitHub API SPDX).
- Latest release: `v3.0.1`, published 2022-06-30T16:24:22Z. No release assets.

## juchong/shapeshifter-docker Dockerfile (d2857ae)
- `FROM alpine`; `ENV ARGS=`; `ADD run.sh /run.sh`; `chmod +x /run.sh`.
- `apk add -U --no-cache git go netcat-openbsd`.
- ENV GOROOT=/usr/lib/go, GOPATH=/go, PATH=/go/bin:$PATH.
- mkdir `${GOPATH}/src`, `${GOPATH}/bin`, `${GOPATH}/shapeshifter-dispatcher`, `/config`.
- `git clone https://github.com/OperatorFoundation/shapeshifter-dispatcher.git` (no ref pinned); `go build && go install` in repo root.
- `EXPOSE 2222/tcp`; `VOLUME /config`; `CMD /run.sh`.
- No USER (root). Arg-driven behaviour lives in run.sh, which is not fetched in this run.

## Ports
- 2222/tcp.

## Volumes/paths
- `/config` (VOLUME in upstream Dockerfile). Chart uses `/state` instead.

## Runtime deps
- Go-built dispatcher binary, netcat (not used by chart args).

## Gotchas
- run.sh not fetched (argument mapping from ARGS unverified here).
- Upstream image is alpine and built from git HEAD; no pinned version.
