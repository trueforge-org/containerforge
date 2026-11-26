# Context sources: picoshare

| Source URL | Summary file |
| --- | --- |
| https://github.com/mtlynch/picoshare | github-mtlynch-picoshare.md |
| https://raw.githubusercontent.com/mtlynch/picoshare/v1.5.5/README.md | github-mtlynch-picoshare.md |
| https://github.com/mtlynch/picoshare/blob/v1.5.5/Dockerfile | github-mtlynch-picoshare.md (raw v1.5.5 read) |
| https://raw.githubusercontent.com/mtlynch/picoshare/v1.5.5/docker-entrypoint | github-mtlynch-picoshare.md |
| https://raw.githubusercontent.com/mtlynch/picoshare/v1.5.5/cmd/picoshare/main.go | github-mtlynch-picoshare.md |
| https://raw.githubusercontent.com/mtlynch/picoshare/v1.5.5/litestream.yml | github-mtlynch-picoshare.md |
| https://github.com/mtlynch/picoshare/releases/download/v1.5.5/picoshare-v1.5.5-linux-amd64.tar.gz | github-mtlynch-picoshare.md (asset pattern and digest; binary not downloaded) |
| https://github.com/mtlynch/picoshare/releases/download/v1.5.5/picoshare-v1.5.5-linux-arm64.tar.gz | github-mtlynch-picoshare.md (asset pattern and digest; binary not downloaded) |
| https://github.com/mtlynch/picoshare/releases/tag/v1.5.5 | github-mtlynch-picoshare.md |
| https://api.github.com/repos/mtlynch/picoshare/releases/tags/v1.5.5 | github-mtlynch-picoshare.md |
| https://api.github.com/repos/mtlynch/picoshare | github-mtlynch-picoshare.md (archive and move metadata) |
| https://codefloe.com/mtlynch/picoshare | codefloe-mtlynch-picoshare.md |
| https://hub.docker.com/r/mtlynch/picoshare | dockerhub-mtlynch-picoshare.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/picoshare | truecharts-picoshare.md |

## Skipped URLs

- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu (containerforge `apps/<base>` link)
- https://cla-assistant.io/trueforge-org/containerforge (CLA link; noted for reference)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json (forgetool schema URL)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json (forgetool schema URL)
- ghcr.io/trueforge-org/ubuntu:26.04@sha256:... (image ref, not a web page)
- docker.io/mtlynch/picoshare:v1.5.5 (image ref; covered by the Docker Hub and chart entries)
- https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-{amd64,arm64}.tar.gz (direct archive downloads; pattern from upstream Dockerfile; not downloaded)
- https://raw.githubusercontent.com/mtlynch/picoshare/v1.5.5/LICENSE and https://raw.githubusercontent.com/benbjohnson/litestream/v0.3.13/LICENSE (plan's license-copy sources; not fetched in this pass)
- https://github.com/mtlynch/picoshare/releases/download/v1.5.5/picoshare-v1.5.5-linux-armv7.tar.gz (direct archive download; name recorded)
- https://demo.pico.rocks (live demo, Docker Hub page; not needed for build)

## Fetch failures

- `https://github.com/mtlynch/picoshare/releases/tag/v1.5.5`: page fetched; asset list showed an error and did not load (file names taken from the API).
- None otherwise.

## plan.md corrections

- None made. Checked against source: port default `4001` (`PORT`, code), draft's `8080` wrong; `PS_SHARED_SECRET_FILE` precedence; `PS_BEHIND_PROXY`; `-db` default `data/store.db`; upstream Dockerfile (`alpine:3.24.4` final stage, `/app/litestream`, `/app/docker-entrypoint`, `/etc/litestream.yml`, `CMD ["-db", "/data/store.db"]`); Litestream `v0.3.13` pin; `LITESTREAM_PATH=db` and `LITESTREAM_RETENTION=72h`; asset names and GitHub digests (amd64 `sha256:72ab7116...`, arm64 `sha256:94559027...`); plan's claim that upstream moved to codefloe.com (GitHub API `description`/`homepage`).
- Unverified (not edited): plan's "AGPL-3.0-or-later" SPDX (the README says only "AGPL"; LICENSE not fetched).
- Unverified (not edited): plan's `PS_SHARED_SECRET` "1 to 100 characters" (the validator `picoshare.NewPassphrase` was not read).
- Unverified (not edited): plan's "Latest litestream is v0.5.18" and "0.5 changed the config format".
- Unverified (not edited): plan's claim that the amd64 tarball contains one file `picoshare` (the tarball was not downloaded; the Dockerfile's `COPY --from=builder /app/bin/picoshare` supports the single-binary layout).
- Unverified (not edited): plan's `handlers/upload.go` `ParseMultipartForm` 1 MiB detail and the `X-Forwarded-Proto` redirect note in section 8.
- Noted (not edited, plan already says it): Docker Hub text gives default port 3001 and Litestream 0.3.8; the source gives 4001 and 0.3.13. The plan follows the source.
- Noted (not edited): the new home (codefloe) lists 47 releases; the plan's Renovate `github-releases` tracking targets the archived GitHub repo, so future bumps may stop. Plan already flags this as UNVERIFIED.
