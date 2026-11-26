# Docker Hub accetto/ubuntu-vnc-xfce-freecad-g3

Source URL(s) + fetch date:
- https://hub.docker.com/r/accetto/ubuntu-vnc-xfce-freecad-g3 (fetched 2026-11-26, WebFetch summary; JS-rendered page, tags/architectures partly missing)

What it is: headless FreeCAD desktop image (G3 v7 family) by accetto. Ubuntu 24.04 LTS, Xfce desktop, TigerVNC server, noVNC client, Mesa3D and VirtualGL, tini as PID 1, sudo, jq, nano, mousepad.

Tags: `latest` (VNC/noVNC, Mesa3D, VirtualGL), `chromium` (adds Chromium, from Ubuntu 18.04 distribution, no-sandbox), `firefox` (adds Firefox, Mozilla Team PPA non-snap build).

Architectures: not listed on the page (the copy-from arm64 = no assumption in draft is UNVERIFIED here).

Size and runtime notes (from page): image about 1 GB; FreeCAD AppImage about 950 MB; AppImage is extracted at app launch (a few seconds); the page notes screenshots show an older FreeCAD version and the repository may hold images with older versions. Last updated over 1 year ago (page text). 50K+ pulls.

Ports: 5901 (VNC, tcp), 6901 (noVNC, http).

Env/usage: env vars, VNC parameters, user/group overrides are documented in the User Guide (see the sub-page section below).

Volumes: none described on the page.

Links listed on the page: User Guide https://accetto.github.io/user-guide-g3/ ; repo https://github.com/accetto/headless-drawing-g3/ ; Dockerfile https://github.com/accetto/headless-drawing-g3/blob/master/docker/Dockerfile.xfce.drawing ; readme https://github.com/accetto/headless-drawing-g3/blob/master/docker/xfce-freecad/README.md ; changelog https://github.com/accetto/headless-drawing-g3/blob/master/CHANGELOG.md.

## Section: User Guide "Using containers" index (https://accetto.github.io/user-guide-g3/using-containers/, fetched 2026-11-26)
- Index page only. Subpages listed: container startup, container user, overriding user, overriding ENVV, overriding VNC, installing packages, shared memory, WebGL support, Firefox Plus, version sticker, keeping data (volumes, bind mounts), Compose.
- No concrete values were in the index page text. Not followed further.

Gotchas:
- Page says the image is not rootless (`sudo`, root-capable). Upstream does not ship a read-only-rootfs design.
- Lists 5901 and 6901 as the exposed ports, which matches the plan.md section 1 table row for this repo, not the KasmVNC 3000/3001 ports.

Failed to fetch: none for the Hub page. The user guide subpages (Overriding ENVV, Overriding VNC) were not fetched.
