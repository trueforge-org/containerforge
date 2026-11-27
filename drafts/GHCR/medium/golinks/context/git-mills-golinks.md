# Upstream: prologic/golinks (git.mills.io) Dockerfile, start.sh, Makefile, go.mod, README, releases

## Source URL(s) + date
- https://git.mills.io/prologic/golinks/raw/branch/master/Dockerfile (fetched 2026-11-27, master)
- https://git.mills.io/prologic/golinks/raw/branch/master/.dockerfiles/start.sh (fetched 2026-11-27)
- https://git.mills.io/prologic/golinks/raw/branch/master/Makefile (fetched 2026-11-27)
- https://git.mills.io/prologic/golinks/raw/branch/master/go.mod (fetched 2026-11-27)
- https://git.mills.io/prologic/golinks/raw/branch/master/README.md (fetched 2026-11-27)
- https://git.mills.io/api/v1/repos/prologic/golinks/releases?limit=3 (fetched 2026-11-27)
- Note: Dockerfile/start.sh are from master, not the v0.0.7 tag the plan pins. Not verified identical at the tag.

## What it is
- golinks: web app; set browser default search to `http://<host>:8000/?q=%s` for smart bookmarks/aliases. Go module `git.mills.io/prologic/golinks`, `go 1.13`.
- Upstream GitHub `prologic/golinks` is a pointer to git.mills.io.

## Build (Dockerfile, master)
| Stage | Base | Steps |
| --- | --- | --- |
| build | `golang:alpine` | `ARG TAG`, `ARG BUILD`; `apk add git make build-base`; `WORKDIR /go/src/git.mills.io/prologic/golinks`; `COPY . ...`; `make TAG=$TAG BUILD=$BUILD build` |
| runtime | `alpine:latest` | `COPY .dockerfiles/start.sh /start.sh`; `COPY --from=build .../golinks /usr/local/bin/golinks`; `EXPOSE 8000/tcp`; `ENTRYPOINT ["/start.sh"]`; `CMD []` |

- Makefile build: `CGO_ENABLED=0`, `go build -tags "netgo static_build" -installsuffix netgo ...`; `TAG?=latest`, `BUILD?=-dev`. Deps step `make build: clean deps`.

## Entrypoint/flags (start.sh)
- Env with defaults:
| Name | Default |
| --- | --- |
| BIND | `0.0.0.0:8000` |
| BASEURL | `http://localhost:8000` |
| DBPATH | `/search.db` |
| TITLE | `Search` |
| SEARCHURL | `https://www.google.com/search?q=%s&btnK` |
| SUGGESTURL | `https://suggestqueries.google.com/complete/search?client=firefox&q=%s` |
| CONFIG | empty |
- If `CONFIG` set: `exec golinks -config "$CONFIG"` (ignores other flags). Else `exec golinks -bind -baseURL -dbpath -title -searchURL -suggestURL`.

## Ports
- `EXPOSE 8000/tcp`.

## Volumes/paths
- Binary `/usr/local/bin/golinks`, script `/start.sh`. DB default `/search.db` (not a volume). No VOLUME instruction.

## User/UID
- No USER: root.

## Healthcheck
- None.

## Version/asset naming (releases API)
- Latest tag `v0.0.7`, published 2021-09-06 (`prerelease: false`). Previous tags `v0.0.6`, `v0.0.5` (limit=3 listed three releases).
- v0.0.7 assets:
  - `_0.0.7_linux_amd64.tar.gz`
  - `_0.0.7_linux_arm64.tar.gz`
  - `_0.0.7_darwin_amd64.tar.gz`
  - `_0.0.7_checksums.txt` and `_0.0.7_checksums.txt.sig`
- v0.0.6 assets use different naming: `golinks_0.0.6_Linux_x86_64.tar.gz`, `golinks_0.0.6_Linux_arm64.tar.gz`, `checksums.txt`, `checksums.txt.sig`.
- Tarball: `https://git.mills.io/prologic/golinks/archive/v0.0.7.tar.gz`.

## Arch
- amd64 and arm64 release tarballs exist for v0.0.7 (linux).

## Gotchas
- Release tarballs exist (plan said none): see plan.md corrections in README.
- Dockerfile default DB path `/search.db` is outside `/data`.
- The Dockerfile ARGs `TAG` and `BUILD` feed the Makefile.
- The GitHub mirror has no tags (plan note).
