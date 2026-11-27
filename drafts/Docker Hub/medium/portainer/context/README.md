# Context README: portainer

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/portainer/values.yaml | truecharts-portainer.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/portainer/Chart.yaml | truecharts-portainer.md |
| https://hub.docker.com/v2/repositories/portainer/portainer-ce/ | dockerhub-portainer-ce.md |
| https://hub.docker.com/v2/repositories/portainer/portainer-ce/tags?page_size=10 | dockerhub-portainer-ce.md |
| https://hub.docker.com/v2/repositories/portainer/portainer-ee/ | dockerhub-portainer-ee.md |
| https://hub.docker.com/v2/repositories/portainer/portainer-ee/tags?page_size=10 | dockerhub-portainer-ee.md |
| https://api.github.com/repos/portainer/portainer/releases/latest | github-portainer.md |
| https://raw.githubusercontent.com/portainer/portainer/505380c8eecff08cf513c457494bde91634db9ff/build/linux/Dockerfile | github-portainer.md |

Skipped: CLA/none; forgetool schemas/none; containerforge apps links/none; templated URLs/none; binary downloads (release tarballs and checksum files, not fetched); image refs/none; GitHub repo API (budget); docs.portainer.io install pages and www.portainer.io (budget, not fetched; listed in urls.txt as OTHER).

Failures: none.

## plan.md corrections
- None. Verified: release 2.45.4 (no `v`), `linux-amd64` and `linux-arm64` tarballs and checksum files exist; Dockerfile `EXPOSE 9000 9443 8000`, `VOLUME /data`, `ENTRYPOINT ["/portainer"]`, no USER/ENV; Docker Hub `2.45.4` updated 2026-11-18.
- Unverified conflict (not edited): plan.md line 101-102 cites chart `readOnlyRootFilesystem: true` and `runAsUser 568`. The fetched chart values set no securityContext (may come from TrueCharts common defaults; not confirmed).
- Plan license `Zlib` remains UNVERIFIED (not fetched here; repo LICENSE not read).
