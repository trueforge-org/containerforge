# opengl-desktop-g3 context

| Source URL | File |
| --- | --- |
| https://github.com/accetto/headless-drawing-g3 (raw README) | accetto-readme.md |
| https://github.com/accetto/headless-drawing-g3/blob/master/docker/Dockerfile.xfce | accetto-dockerfile-xfce.md |
| https://raw.githubusercontent.com/accetto/headless-drawing-g3/master/LICENSE | accetto-license.md |
| https://github.com/VirtualGL/virtualgl (GitHub API latest release) | virtualgl-release-latest.md |
| https://github.com/VirtualGL/virtualgl (README) | virtualgl-readme.md (failed) |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/opengl-desktop-g3 (values.yaml) | truecharts-opengl-desktop-g3-values.md |
| https://hub.docker.com/r/accetto/ubuntu-vnc-xfce-opengl-g3 | dockerhub-accetto-opengl-g3.md |

Skipped: none. The `https://github.com/VirtualGL/virtualgl` repo URL is covered by the release API file and the README attempt.

Failures:
- VirtualGL README: main 404 and master 404; not retried further.

## plan.md corrections
- None made. Plan's VirtualGL 3.1.5 (latest, 2026-08-14), the amd64/arm64 deb URLs, accetto ports 5901/6901, MIT license, and base Ubuntu 24.04 with UID 1001 agree with fetched sources.
- Unverified (no edit): plan says LICENSE for VirtualGL is believed wxWindows; no VirtualGL license source fetched here.
- Unverified (no edit): the truecharts chart default VNC_PW is "unraid" and the accetto Dockerfile's default is "headless"; the plan uses kasmvnc PASSWORD and does not depend on either.
