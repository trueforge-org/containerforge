# dizquetv context index

Fetched 2026-11-26. Summaries of every web source referenced by draft.md and plan.md.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/vexorian/dizquetv | github-vexorian-dizquetv.md |
| https://github.com/vexorian/dizquetv/wiki | github-vexorian-dizquetv.md (wiki index and Step 1/Step 3 pages as sections) |
| https://github.com/vexorian/dizquetv/blob/ce37783/Dockerfile-nvidia | github-vexorian-dizquetv.md (nvidia Dockerfile section) |
| https://github.com/vexorian/dizquetv/releases/tag/1.7.0 | github-vexorian-dizquetv.md (release section) |
| https://hub.docker.com/r/vexorian/dizquetv | dockerhub-vexorian-dizquetv.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dizquetv | truecharts-dizquetv.md |

Additional raw files fetched and folded into the summaries above: raw master README.md, raw master Dockerfile, raw master index.js, raw truecharts Chart.yaml and values.yaml.

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (not a source) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/vexorian/dizquetv/archive/refs/tags/${VERSION}.tar.gz | contains `${`, template URL (tarball pattern recorded in the repo summary) |
| https://github.com/vexorian/dizquetv/releases/download/1.7.0/dizquetv-linux-x64 | direct binary download (asset name recorded in repo summary) |

## Not fetched

| Named reference | Reason |
| --- | --- |
| npm package `dizquetv` (draft "1.7.0 npm package") | No URL given; plan.md already records `registry.npmjs.org/dizquetv` as Not Found. Not re-fetched. |

## Fetch failures and partial content

- Release page https://github.com/vexorian/dizquetv/releases/tag/1.7.0: the asset list did not load ("Assets 6" shown, no filenames). Asset names come from the wiki instead.
- TrueCharts chart directory listing returned no Chart.yaml/values.yaml content; fetched those via raw.githubusercontent.com instead (succeeded).

## plan.md corrections

- Section 7 (start.sh): "It binds all interfaces by default (express `listen(port)`); UNVERIFIED in source" -> "It binds all interfaces by default: index.js calls `app.listen(process.env.PORT)` with no host argument (verified in source); still confirm ...". Source: github-vexorian-dizquetv.md (index.js).
- Section 10 (ffmpeg bullet): "ffmpeg 8.0 vs upstream tested ffmpeg 4.3" -> "ffmpeg 8.0 vs upstream requirement "FFMPEG 4.2.3 or later" (wiki; development tested 4.2.4; upstream Docker base 4.3)". Source: github-vexorian-dizquetv.md (wiki Step 3).

## plan.md unverified (not edited)

- Section 1 License `Zlib`: README says zlib covers dizqueTV changes and MIT covers the original pseudotv-Plex code. The plan's single-SPDX claim could not be checked against a LICENSE file here (not fetched). Source: github-vexorian-dizquetv.md.
- Section 1 Release assets (4 named files, no arm64): the release page listing did not render (it says "Assets 6"), so the count and names could not be confirmed here. The wiki names linux-x64, macos-x64, win-x64.exe and win-x86.exe, which agree with the plan. Source: github-vexorian-dizquetv.md.
- Section 1 `ENV`/`PORT`/`DATABASE` and Docker Hub tags: confirmed in index.js and the wiki (no change needed).
