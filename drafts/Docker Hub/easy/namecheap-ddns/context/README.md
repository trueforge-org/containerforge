# Context sources: namecheap-ddns

| Source URL | Summary file |
| --- | --- |
| https://github.com/EdwardChamberlain/namecheap_ddns | github-edwardchamberlain-namecheap-ddns.md |
| https://raw.githubusercontent.com/EdwardChamberlain/namecheap_ddns/main/README.md | github-edwardchamberlain-namecheap-ddns.md |
| https://github.com/EdwardChamberlain/namecheap_ddns/blob/421a554e5267e6405850f0fe302ff95600dc8539/src/dockerfile | github-edwardchamberlain-namecheap-ddns.md |
| https://github.com/EdwardChamberlain/namecheap_ddns/releases | github-edwardchamberlain-namecheap-ddns.md |
| https://hub.docker.com/r/edchamberlain/namecheap_ddns | dockerhub-edchamberlain-namecheap-ddns.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/namecheap-ddns | truecharts-namecheap-ddns.md |

## Skipped URLs

- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu (containerforge `apps/<base>` link)
- https://github.com/trueforge-org/containerforge/tree/main/apps/python (containerforge `apps/<base>` link)
- https://cla-assistant.io/trueforge-org/containerforge (CLA link; not in draft/plan body, noted for reference)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json (forgetool schema URL)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json (forgetool schema URL)
- ghcr.io/trueforge-org/python:3.15.2@sha256:... (image ref, not a web page)
- docker.io/edchamberlain/namecheap_ddns:latest (image ref; covered by the Docker Hub page above)
- https://github.com/EdwardChamberlain/namecheap_ddns/releases/download/... (none exist; releases page is fetched instead)

## Fetch failures

- None.

## plan.md corrections

- No factual corrections. Checked against the sources: Dockerfile base/steps, env var names and defaults (`APP_UPDATE_TIME` 60, `APP_LOG_LEVEL` INFO via `config.py`), endpoint, port (none), no-releases status, chart securityContext (UID/GID 0, rootfs writable) all match.
- Unverified (not edited): the README and plan's "AGPL-3.0-only" SPDX (LICENSE was not fetched; README fetch did not state a license).
- Unverified (not edited): plan says the pinned commit is current as of 2026-11-23; not re-checked against HEAD.
- Noted, not edited (plan already flags it): the README's "every 3 seconds, on change" claim is wrong per code; plan already follows the code.
