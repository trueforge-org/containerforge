# context/ for threadfin

Fetched 2026-11-26.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/Threadfin/Threadfin (README, Dockerfile @c459dd5, threadfin.go @1.2.37, LICENSE @1.2.37, releases page) | github-threadfin-threadfin.md |
| https://github.com/Threadfin/Threadfin/wiki | github-threadfin-threadfin-wiki.md |
| https://hub.docker.com/r/fyb3roptik/threadfin | dockerhub-fyb3roptik-threadfin.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/threadfin (values.yaml) | truecharts-threadfin.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page, not a source.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json: forgetool schema URL.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base link.
- http://localhost:34400/web/: localhost URL.
- https://github.com/Threadfin/Threadfin/releases/download/${VERSION}/Threadfin_linux_${TARGETARCH}, https://github.com/Threadfin/Threadfin/releases/download/1.2.37/Threadfin_linux_amd64, https://github.com/Threadfin/Threadfin/releases/download/1.2.37/Threadfin_linux_arm64: direct binary downloads (asset pattern recorded in the GitHub summary).
- https://github.com/Threadfin/Threadfin/blob/c459dd5a3a3227dfe08143183370a9898185203a/Dockerfile: fetched raw instead.
- https://raw.githubusercontent.com/Threadfin/Threadfin/${VERSION}/LICENSE: fetched at tag 1.2.37 instead.
- Local reference `docs/project-fireball.md` is not a web source.

## Fetch failures

- Releases asset list: the 1.2.37 asset list did not load on the releases page (fetch error). Asset file names and checksum presence are unconfirmed.
- Upstream `src/` package (update logic, web routes, config file names): not fetched, so these are unverified.
- Wiki: empty page, no content.

## plan.md corrections

None made. Items left as unverified (not edited):
- Plan section 10: `ThreadfinAutoUpdate` default of `true`, and that it is `false` only if `/.dockerenv` exists. Not in `threadfin.go` (1.2.37); the logic lives in the un-fetched `src` package. Unverified.
- Plan section 8: UI path `/web/` for the HTTP probe. No route is documented in the fetched sources. Unverified.
- Plan section 1 and 4: asset names `Threadfin_linux_amd64` and `Threadfin_linux_arm64` and the arm64 HTTP 200. The asset list failed to load; unverified here.
- Plan section 9: `/home/threadfin/cache` being inside `-config`. The Dockerfile creates `THREADFIN_CACHE=/home/threadfin/cache` as a separate path. Unverified how the binary uses it.
- Plan section 1: `vlc` and `jellyfin-ffmpeg7` are included upstream (verified). Plan section 4 omits them intentionally; no change.
