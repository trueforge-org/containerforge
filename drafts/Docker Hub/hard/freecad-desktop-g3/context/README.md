# Context: freecad-desktop-g3

Fetched 2026-11-26.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://raw.githubusercontent.com/accetto/headless-drawing-g3/master/docker/Dockerfile.xfce.drawing.freecad | github-accetto-headless-drawing-g3.md |
| https://github.com/accetto/headless-drawing-g3 | github-accetto-headless-drawing-g3.md |
| https://raw.githubusercontent.com/FreeCAD/FreeCAD/main/README.md | github-freecad-freecad.md |
| https://github.com/FreeCAD/FreeCAD/releases | github-freecad-freecad.md |
| https://github.com/FreeCAD/FreeCAD | github-freecad-freecad.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/freecad-desktop-g3 | truecharts-freecad-desktop-g3.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/freecad-desktop-g3/values.yaml | truecharts-freecad-desktop-g3.md |
| https://hub.docker.com/r/accetto/ubuntu-vnc-xfce-freecad-g3 | dockerhub-accetto-ubuntu-vnc-xfce-freecad-g3.md |
| https://accetto.github.io/user-guide-g3/using-containers/ | dockerhub-accetto-ubuntu-vnc-xfce-freecad-g3.md (section) |
| https://www.freecad.org | docs-freecad-org.md |
| https://wiki.freecad.org | docs-wiki-freecad-org.md (blocked) |

Shared index (`/workspaces/containers/docs/context/INDEX.md`): no matches for these URLs.

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link, not a source |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps base link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL (plan.md) |
| ghcr.io/trueforge-org/ubuntu, ghcr.io/trueforge-org/kasmvnc | ghcr image refs, not web pages |
| https://github.com/FreeCAD/FreeCAD/releases/download/... and AppImage URLs | direct binary downloads |
| SourceForge AppImage/SHA256 URLs (plan.md, no full URL given) | direct binary downloads, not fetched |

## Fetch failures

- https://wiki.freecad.org/Main_Page: Anubis access denied (error 9e4edb5b6b850c41).
- https://wiki.freecad.org/index.php?title=Main_Page&action=raw: same Anubis block.
- GitHub releases page: only the first page was read, and the asset list failed to load. Stable release assets were not confirmed.
- Docker Hub page is JS-rendered; architectures and full tag list were not in the fetched text.

## plan.md corrections

No clear factual errors were found in plan.md. Items that could not be confirmed (no edit made):

- unverified: plan.md section 1 says "Version 1.1.4 (latest stable per freecad.org downloads)". freecad.org links to "Release_notes_1.1" but gives no number. The first page of the GitHub releases list shows only pre-releases (weekly-* and 26.3rc1/rc2). The stable release is not on page 1, so 1.1.4 remains unverified.
- unverified: plan.md "x86_64 AppImage name and checksum file name" (only aarch64 was seen earlier; this fetch could not list assets).
- unverified: plan.md "License LGPL-2.1-or-later" (not stated in fetched FreeCAD pages).

