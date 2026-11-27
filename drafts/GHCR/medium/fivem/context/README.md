# fivem context

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fivem/values.yaml + Chart.yaml | truecharts-fivem.md |
| https://raw.githubusercontent.com/ich777/docker-fivem-server/master/Dockerfile | github-ich777-fivem-dockerfile.md |
| https://raw.githubusercontent.com/ich777/docker-fivem-server/master/scripts/start.sh | github-ich777-fivem-start.md |
| https://docs.fivem.net/docs/server-download/?platform=legacy&os=linux | fivem-server-download-docs.md |
| https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master | fivem-server-download-docs.md (returns docs HTML, see gotchas) |

Skipped: Docker Hub (image is ghcr.io/ich777/fivemserver, no Docker Hub page); https://fivem.net (marketing); https://github.com/citizenfx/fivem (repo root, not fetched); https://github.com/ich777/docker-fivem-server/blob/master/Dockerfile (blob duplicate of raw); binary artifact `fx.tar.xz` downloads (not downloaded).

Failures: none.

## plan.md corrections
- Version row: "The FiveM docs page ... lists only the Windows artifact (build 38435)." -> "lists Linux `build_proot_linux` artifacts up to build 38781 and a Windows "Latest" block for build 38435 (fetched 2026-11-27)." Source: fivem-server-download-docs.md.
- Unverified (not changed): the plan's "no LATEST file" conclusion is consistent with the runtime URL returning HTML. Runtime license terms remain unverified.
