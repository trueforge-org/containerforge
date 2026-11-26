# inkscape-desktop-g3 context

| Source URL | File |
| --- | --- |
| https://github.com/accetto/headless-drawing-g3/blob/master/docker/Dockerfile.xfce.drawing | github-accetto-headless-drawing-g3-dockerfile.md |
| https://github.com/accetto/headless-drawing-g3 (README, via raw master) | github-accetto-headless-drawing-g3-readme.md |
| https://hub.docker.com/r/accetto/ubuntu-vnc-xfce-inkscape-g3 | dockerhub-accetto-ubuntu-vnc-xfce-inkscape-g3.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/inkscape-desktop-g3 | truecharts-inkscape-desktop-g3.md (via raw values.yaml; tree page not fetched) |
| https://gitlab.com/inkscape/inkscape | gitlab-inkscape-inkscape.md |
| https://inkscape.org | inkscape-org-home.md |
| https://wiki.inkscape.org/wiki/Main_Page | wiki-inkscape-main-page.md |

Skipped: none of the listed categories applied.

Failures: 0.

## plan.md corrections
None edited. Checked against fetched sources: PPA `ppa:inkscape.dev/stable`, `tini` + `/dockerstartup/startup.sh`, user headless UID 1001, env var names/defaults, ports 5901/6901, license category all match.
Unverified conflict (no edit):
- plan.md ships Inkscape 1.4.3 (Ubuntu resolute apt). inkscape.org (fetched 2026-11-26) lists 1.4.4 as current stable. The wiki Main_Page calls 1.4.3 the current bug-fix release and 1.4.4 a future one. The sources disagree with each other. Apt version was not checked.
