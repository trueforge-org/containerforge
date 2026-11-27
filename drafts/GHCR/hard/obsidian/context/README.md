# Context: obsidian

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/obsidian/values.yaml + Chart.yaml | truecharts-obsidian.md |
| https://raw.githubusercontent.com/sytone/obsidian-remote/ac1c8e6c.../Dockerfile (+ blob variant) | sytone-obsidian-remote-dockerfile.md |
| https://raw.githubusercontent.com/sytone/obsidian-remote/main/README.md | sytone-obsidian-remote-readme.md |
| https://github.com/obsidianmd/obsidian-releases/releases/latest (alt for API 403) | obsidian-releases-latest.md |
| https://help.obsidian.md, https://obsidian.md | obsidian-help-and-site.md |

Skipped: https://github.com/obsidianmd/obsidian-releases (repo root, not fetched; releases page used); https://github.com/obsidianmd/obsidian-releases/releases/latest was fetched as the alt; https://github.com/sytone/obsidian-remote (repo root, covered by raw files); https://github.com/sytone/obsidian-remote/pkgs/container/obsidian-remote (GHCR package page, not fetched); no Docker Hub source (GHCR image).

Failures:
- https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest: HTTP 403; alternative used.

## plan.md corrections
- No edit made. Confirmed (not corrected): upstream image runs Obsidian 0.15.9 (sytone Dockerfile ARG), plan.md line 15 consistent. Chart pins sytone tag 0.1.1 (not Obsidian version).
- Confirmed: github releases/latest redirect shows v1.15.1 (plan.md line 8 and VERSION 1.15.1 consistent).
- UNVERIFIED conflict: plan.md lists upstream env `TITLE=Obsidian v$OBSIDIAN_VERSION` (matches Dockerfile). README lists TITLE default "KasmVNC Client" and PASSWORD default conflict; plan.md line 22 already notes the PASSWORD conflict.
