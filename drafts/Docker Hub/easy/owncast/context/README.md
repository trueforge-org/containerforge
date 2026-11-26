# Context sources: owncast

| Source URL | Summary file |
| --- | --- |
| https://github.com/owncast/owncast | github-owncast-owncast.md |
| https://raw.githubusercontent.com/owncast/owncast/v0.3.0/README.md | github-owncast-owncast.md |
| https://github.com/owncast/owncast/blob/4b09a1b11693977400fb6f6cb06a7b9891bdca6d/Dockerfile | github-owncast-owncast.md (v0.3.0 Dockerfile read instead; pinned blob not fetched) |
| https://github.com/owncast/owncast/releases/download/v0.3.0/owncast-0.3.0-linux-64bit.zip | github-owncast-owncast.md (asset pattern; binary not downloaded) |
| https://github.com/owncast/owncast/releases/download/v0.3.0/owncast-0.3.0-linux-arm64.zip | github-owncast-owncast.md (asset pattern; binary not downloaded) |
| https://owncast.online/docs/ | docs-owncast-online-docs.md |
| https://owncast.online/docs/configuration/runtime-flags/ | docs-owncast-online-runtime-flags.md |
| https://owncast.online/docs/configuration/server-setup/ | docs-owncast-online-server-setup.md |
| https://owncast.online/ | not fetched separately (docs landing page covers the product; listed in draft) |
| https://hub.docker.com/r/gabekangas/owncast | dockerhub-gabekangas-owncast.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/owncast | truecharts-owncast.md |

## Skipped URLs

- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu (containerforge `apps/<base>` link)
- https://cla-assistant.io/trueforge-org/containerforge (CLA link; noted for reference)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json (forgetool schema URL)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json (forgetool schema URL)
- ghcr.io/trueforge-org/ubuntu:26.04@sha256:... (image ref, not a web page)
- docker.io/gabekangas/owncast:0.3.0 (image ref; covered by the Docker Hub page)
- https://github.com/owncast/owncast/releases/download/v0.3.0/owncast-0.3.0-linux-64bit.zip and `...-linux-arm64.zip` (direct binary zips; pattern recorded in the GitHub summary)
- https://owncast.online/docs/sslproxies/ (linked from the server-setup page; not in draft/plan)

## Fetch failures

- None.

## plan.md corrections

- None. Checked against source: version `0.3.0` and published date, asset names (`owncast-0.3.0-linux-64bit.zip`, `...-linux-arm64.zip`), no checksum asset, upstream Dockerfile runtime (`alpine:3.24.0`, ffmpeg, UID 101 `owncast`, `/app/data`, `EXPOSE 8080 1935`, `ENTRYPOINT ["/app/owncast"]`), MIT license, flag names and defaults (`--database` `data/owncast.db`, `--webserverport` 8080, `--rtmpport` 1935, flags saved to DB), admin at `/admin`.
- Unverified (not edited): plan says `--webserverip` defaults to `0.0.0.0`. The docs give `0.0.0.0` only for the RTMP address; the webserverip default is not stated.
- Unverified (not edited): plan says the default admin password and stream key are both `abc123` (from `config/defaults.go`). Docs state no default; the config source was not fetched.
- Unverified (not edited): plan says ffmpeg is looked up as `./ffmpeg` then `PATH`. Docs only describe an absolute-path setting; source not fetched.
- Unverified (not edited): plan says the amd64 zip has only the binary and no LICENSE, and the arm64 zip layout is unknown; zips not downloaded.
- Unverified (not edited): plan's list of runtime write paths under `data/` came from source reading, not fetched here.
- Noted (not edited): the Docker Hub `latest` digest (`sha256:4e9ef8e99...`) differs from the digest the chart pins for `0.3.0` (`efca3c28...`); the chart pin was not checked against the upstream tag.
