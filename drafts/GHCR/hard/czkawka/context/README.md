# Context: czkawka

| Source URL | File | Status |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/czkawka/values.yaml | truecharts-czkawka.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/czkawka/Chart.yaml | truecharts-czkawka.md | fetched |
| https://github.com/jlesage/docker-czkawka | github-jlesage-docker-czkawka-readme.md | repo root HTML fetched; facts taken from README |
| https://raw.githubusercontent.com/jlesage/docker-czkawka/v26.09.2/README.md | github-jlesage-docker-czkawka-readme.md | fetched (follow-up) |
| https://raw.githubusercontent.com/jlesage/docker-czkawka/v26.09.2/Dockerfile | github-jlesage-docker-czkawka-dockerfile.md | fetched |
| https://github.com/jlesage/docker-czkawka/blob/v26.09.2/Dockerfile | github-jlesage-docker-czkawka-dockerfile.md | same file as raw |
| https://github.com/qarmin/czkawka | github-qarmin-czkawka-release.md | not fetched as HTML; GitHub API used instead: https://api.github.com/repos/qarmin/czkawka/releases/latest |

Skipped categories: none beyond the templated icon URL (https://github.com/jlesage/docker-templates/raw/master/jlesage/images/czkawka-icon.png, referenced in the Dockerfile, not in urls.txt), libheif and czkawka source tarballs (binary/source downloads inside the Dockerfile, not fetched), and the Docker Hub check (image is ghcr.io/jlesage/czkawka; no Docker Hub URL in this app, so no dockerhub-*.md).

Failures: none.

## plan.md corrections
- No edits made. Plan facts checked against fetched sources: release 12.0.2 date, asset sha256 values (cli/gui x86_64 and arm64, heif_raw_avif variants), Dockerfile base and build stages, VOLUME /storage, GTK EOL note. All matched.
- Verified now (plan line 17 was UNVERIFIED): upstream README documents web GUI on 5800 and VNC on 5900 for the GUI image. Plan's CLI-only design (no port) is unchanged.
- Unverified conflict: plan.md uses chart image tag `v26.09.2` (line 8, via the draft). The current TrueCharts chart pins `ghcr.io/jlesage/czkawka:v26.11.2@sha256:98ac101b...` with appVersion 26.11.2. Not verified whether v26.11.2 still builds czkawka 12.0.2 (its Dockerfile was not fetched, outside the urls list).
- Unverified conflict: the chart mounts trash at `/trash`; upstream README puts trash at `/config/xdg/data/Trash`. Plan already flags `/trash` as a draft extra mount (line 171).
