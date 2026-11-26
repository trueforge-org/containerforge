# dropbox-by-otherguy context index

Fetched 2026-11-26. Summaries of every web source referenced by draft.md and plan.md.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/otherguy/docker-dropbox | github-otherguy-docker-dropbox.md |
| https://github.com/otherguy/docker-dropbox/blob/master/Dockerfile (fetched as raw) | github-otherguy-docker-dropbox.md (Dockerfile section) |
| raw master/docker-entrypoint.sh (plan's entrypoint facts) | github-otherguy-docker-dropbox.md (entrypoint flow section) |
| https://hub.docker.com/r/otherguy/dropbox | dockerhub-otherguy-dropbox.md |
| https://www.dropbox.com/install | docs-dropbox-com-install.md |
| https://help.dropbox.com/ | docs-help-dropbox-com.md |
| https://www.dropbox.com/ | dropbox-com.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dropbox-by-otherguy | truecharts-dropbox-by-otherguy.md (directory not fetched; values.yaml fetched via raw URL) |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (not a source) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://www.dropbox.com/download/?plat=lnx.x86_64 (also written `/download?plat=lnx.x86_64` in draft) | download endpoint redirecting to the daemon tarball (direct binary download); asset pattern recorded in github-otherguy-docker-dropbox.md |
| https://www.dropbox.com/download?dl=packages/dropbox.py | download endpoint for the CLI helper script (direct download); behaviour recorded from the entrypoint |

## Fetch failures

- None. All non-skipped URLs returned content.
- Not fetched: the wrapper's `monitoring.py` (copied into the image, referenced in the Dockerfile; not a draft URL).

## plan.md corrections

- Section 1, Downloads row: the URL was written `https://www.dropbox.com/download?plat=lnx.x86_64`; the entrypoint uses `https://www.dropbox.com/download/?plat=lnx.x86_64` (slash before `?`). Edited to match. Source: github-otherguy-docker-dropbox.md.
- Section 1, License row: "Wrapper scripts: UNVERIFIED" -> MIT, per the wrapper README (`LICENSE.md`). Edited; the LICENSE.md text itself was not fetched. Source: github-otherguy-docker-dropbox.md.
- Section 7, account-linking note: "UNVERIFIED in this image" -> confirmed by the wrapper README (`docker logs --follow` shows the auth URL; success "This computer is now linked to Dropbox."). Edited. Source: github-otherguy-docker-dropbox.md.

## plan.md unverified (not edited)

- Section 1, Downloads: "Dropbox does not publish an arm64 Linux daemon in this flow". The Dockerfile and entrypoint only use `lnx.x86_64`, but no Dropbox page confirmed the absence. Source: github-otherguy-docker-dropbox.md, docs-dropbox-com-install.md.
- Section 6, port 17500: the Dockerfile comment says it is "not strictly needed with host networking"; no source states its role (LAN sync). Source: github-otherguy-docker-dropbox.md.
- Section 10, "Dropbox supports only certain filesystems (ext4 etc.)": the README says Dropbox dropped support for several Linux filesystems but does not name them. Source: github-otherguy-docker-dropbox.md.
- Draft persistence: the wrapper README quickstart mounts the settings volume at `/opt/dropbox`, while Hub and TrueCharts use `/opt/dropbox/.dropbox`. Not a plan edit. Source: dockerhub-otherguy-dropbox.md, truecharts-dropbox-by-otherguy.md.
