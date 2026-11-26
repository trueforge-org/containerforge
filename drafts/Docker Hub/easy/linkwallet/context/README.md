# linkwallet: context sources

Fetched 2026-11-26. Summaries for every web source referenced by `draft.md` and `plan.md`.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/tardisx/linkwallet (+ raw README, Dockerfile at main and 59f70ae, LICENSE, .goreleaser.yaml, cmd/linkwallet/linkwallet.go, web/web.go, releases) | github-tardisx-linkwallet.md |
| https://github.com/tardisx/linkwallet/blob/59f70ae/Dockerfile and `.../blob/main/Dockerfile` | github-tardisx-linkwallet.md (raw Dockerfiles, identical) |
| https://code.ppl.town/justin/linkwallet (plan's moved upstream, Forgejo) and /releases | code-ppl-town-justin-linkwallet.md |
| https://hub.docker.com/r/tardisx/linkwallet | dockerhub-tardisx-linkwallet.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/linkwallet (Chart.yaml and values.yaml via raw) | truecharts-linkwallet.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page, skipped by rule |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base link, skipped by rule |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema, skipped by rule |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema, skipped by rule |
| https://github.com/tardisx/linkwallet/releases/download/v${VERSION}/linkwallet_Linux_${a}.tar.gz | templated release download. Pattern recorded in github-tardisx-linkwallet.md |
| https://github.com/tardisx/linkwallet/releases/download/v${VERSION}/linkwallet_${VERSION}_checksums.txt | templated release download. Pattern recorded in github-tardisx-linkwallet.md |
| https://github.com/tardisx/linkwallet/releases/download/v0.1.1/linkwallet_Linux_x86_64.tar.gz (x2) | direct release download. Pattern recorded in github-tardisx-linkwallet.md |
| https://github.com/tardisx/linkwallet/releases/download/v0.1.1/linkwallet_Linux_arm64.tar.gz (x2) | direct release download. Pattern recorded in github-tardisx-linkwallet.md |
| http://<container-ip>:8080 | placeholder address in plan section 11, not a source |

Named but not fetched: the `version` package and `db` package (GitHub API URL for version check; bolt/bleve setup; code in the Go module, not on a web page linked from draft/plan), the docker-compose sample (`docker-compose.yml-sample`, linked from README only as a file name), `alpine:3.16` base image (upstream Dockerfile base, not a reference link).

## Fetch failures

- https://raw.githubusercontent.com/tardisx/linkwallet/main/main.go: HTTP 404. Alternative tried: https://raw.githubusercontent.com/tardisx/linkwallet/main/cmd/linkwallet/linkwallet.go (the goreleaser and README build entry point), which succeeded.
- https://code.ppl.town/justin/linkwallet/releases/... per-release checksum files: not fetched (direct downloads). The plan's checksum values could not be read.
- https://github.com/tardisx/linkwallet/releases: asset names not listed on the page ("12 assets" only). Tag and date loaded.

## plan.md corrections

No edits made. No fact in plan.md was clearly wrong against the fetched sources.

Confirmed: `-db-path` mandatory (`log.Fatal` when empty); `PORT` env (default 8080) via gin; `GIN_MODE` honored by gin; Dockerfile `FROM alpine:3.16` / `ENTRYPOINT ["/linkwallet"]` / `COPY linkwallet /`; goreleaser `CGO_ENABLED=0`; `v0.1.1` latest on Forgejo and by date on GitHub; archive 2025-05-23; move to code.ppl.town; MIT license; root route `GET /` serves the search page; version check interval 6 hours; chart uses `/data` with `-db-path /data/linkwallet.db`; Docker Hub digest prefix `5828c5f14` matches the chart.

Resolved open question (no edit, for the author): plan section 1 "Auth ... UNVERIFIED whether any login exists". `web/web.go` has no login route and no auth middleware, so there is no app-level auth in the fetched code.

Unverified (not edited):
- plan.md section 1 (Downloads row): amd64 binary is statically linked and stripped (`file`). Not checked; goreleaser `CGO_ENABLED=0` is consistent.
- plan.md section 1 (Downloads row): each tarball holds `linkwallet`, `LICENSE`, `README.md`. Not verified; not fetched.
- plan.md section 1 (Checksum row): sha256 values `cc0710ac...` (amd64) and `ce4aa3c0...` (arm64) from `linkwallet_0.1.1_checksums.txt`. The checksum file was not fetched; the Forgejo page shows no hash values.
- plan.md section 1 (CLI row): bolthold file plus Bleve index at `<path>.bleve`. Set up in the `db` package, not fetched.
- plan.md section 1 (Other env row): `GIN_MODE=release` "read by gin to silence debug output". Consistent with gin behaviour, not documented by linkwallet.
- plan.md section 1 (Upstream Dockerfile row): docker-compose sample entrypoint `['/linkwallet','-db-path','/data/linkwallet.db']`. The README says a sample exists but does not show its contents.
- plan.md section 10: "calls GitHub for a version check every 6 hours". Interval confirmed (`linkwallet.go`); the GitHub API URL is in the `version` package, not fetched.
- plan.md section 10: "Renovate ... tracking the Forgejo host would need a different datasource (UNVERIFIED which one works)". Not checked.
