# Context sources: ntfy

| Source URL | Summary file |
| --- | --- |
| https://github.com/binwiederhier/ntfy | github-binwiederhier-ntfy.md |
| https://raw.githubusercontent.com/binwiederhier/ntfy/v2.38.2/Dockerfile (draft link: blob/v2.38.1/Dockerfile) | github-binwiederhier-ntfy.md |
| https://raw.githubusercontent.com/binwiederhier/ntfy/v2.38.2/server/server.yml | github-binwiederhier-ntfy.md |
| https://github.com/binwiederhier/ntfy/releases/tag/v2.38.2 | github-binwiederhier-ntfy.md |
| https://api.github.com/repos/binwiederhier/ntfy/releases/tags/v2.38.2 | github-binwiederhier-ntfy.md |
| https://docs.ntfy.sh/ | docs-ntfy-sh-install.md (install page fetched; root not fetched separately) |
| https://docs.ntfy.sh/install/ | docs-ntfy-sh-install.md |
| https://docs.ntfy.sh/config/ | docs-ntfy-sh-config.md |
| https://hub.docker.com/r/binwiederhier/ntfy | dockerhub-binwiederhier-ntfy.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ntfy | truecharts-ntfy.md |

## Skipped URLs

- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu (containerforge `apps/<base>` link)
- https://cla-assistant.io/trueforge-org/containerforge (CLA link; noted for reference)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json (forgetool schema URL)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json (forgetool schema URL)
- ghcr.io/trueforge-org/ubuntu:26.04@sha256:... (image ref, not a web page)
- https://github.com/binwiederhier/ntfy/releases/download/v2.38.2/ntfy_2.38.2_linux_amd64.deb and `..._linux_arm64.deb` (direct binary downloads; asset pattern recorded in github summary)
- https://github.com/binwiederhier/ntfy/releases/download/v2.38.2/ntfy_2.38.2_linux_amd64.tar.gz and `..._linux_arm64.tar.gz` (direct archive downloads; pattern recorded)
- https://github.com/binwiederhier/ntfy/releases/download/v2.38.2/checksums.txt (not fetched: 302 to a signed release-asset URL the fetch tool does not follow; see Fetch failures)
- https://raw.githubusercontent.com/binwiederhier/ntfy/v2.38.2/LICENSE.GPLv2 (plan's link; not in draft, not fetched)
- docker.io/binwiederhier/ntfy:v2.38.1 (image ref; covered by Docker Hub page)

## Fetch failures

- `checksums.txt` via `releases/download/v2.38.2/checksums.txt`: 302 redirect to a signed `release-assets.githubusercontent.com` URL that the fetch tool does not follow. Not retried (signed, short-lived URL).
- `https://github.com/binwiederhier/ntfy/releases/tag/v2.38.2`: asset list rendered as "Loading" and did not load; asset names taken from the GitHub API instead.
- `https://docs.ntfy.sh/config/`: page truncated before the "Health checks" and "Monitoring" sections (fetch tool output limit); the health endpoint was confirmed from `https://docs.ntfy.sh/install/` instead.

## plan.md corrections

- None. Checked against source: Dockerfile (`FROM alpine`, `EXPOSE 80/tcp`, `ENTRYPOINT ["ntfy"]`, no USER); version `2.38.2` and published date; asset names `ntfy_2.38.2_linux_amd64.tar.gz` and `..._linux_arm64.tar.gz`; `checksums.txt` exists in the release; server.yml defaults (`listen-http :80`, `cache-file` unset, `auth-file` unset, `attachment-cache-dir` unset, `behind-proxy false`, `web-root /`, `auth-default-access read-write`); `/v1/health` endpoint (docs install page); `NTFY_` env naming.
- Unverified (not edited): plan says `NTFY_CONFIG_FILE` is an env var; not present in fetched text.
- Unverified (not edited): plan says the amd64 tarball contains `LICENSE` but not `LICENSE.GPLv2`, and that the arm64 tarball layout is unknown; tarballs were not downloaded.
- Unverified (not edited): plan says `upstream-base-url` requires `base-url`; the fetched docs do not state this.
- Unverified (not edited): plan says `/v1/health` is in `server/server.go`; only the docs example was checked, not the source.
