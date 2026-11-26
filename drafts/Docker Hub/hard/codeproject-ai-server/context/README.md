# codeproject-ai-server: source context (fetched 2026-11-26)

## Sources fetched

| Source URL | Summary file |
| --- | --- |
| https://raw.githubusercontent.com/codeproject/CodeProject.AI-Server/master/README.md | codeproject-github-repo.md |
| https://github.com/codeproject/CodeProject.AI-Server/releases | codeproject-github-repo.md |
| https://github.com/codeproject/CodeProject.AI-Server | codeproject-github-repo.md |
| https://codeproject.github.io/codeproject.ai/install/install_on_linux.html | codeproject-docs-install-linux.md |
| https://codeproject.github.io/codeproject.ai/ | codeproject-docs-install-linux.md |
| https://hub.docker.com/r/codeproject/ai-server | codeproject-dockerhub.md |
| https://dot.net/v1/dotnet-install.sh (301 to builds.dotnet.microsoft.com) | codeproject-dotnet-install-script.md |
| https://builds.dotnet.microsoft.com/dotnet/scripts/v1/dotnet-install.sh | codeproject-dotnet-install-script.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/codeproject-ai-server (values.yaml) | truecharts-codeproject-ai-server.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (never fetched) |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base app link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge base app link |
| https://codeproject-ai-bunny.b-cdn.net/server/installers/linux/codeproject.ai-server_${VERSION}_Ubuntu_x64.zip | direct archive download; pattern in codeproject-cdn-and-deb.md |
| https://codeproject-ai-bunny.b-cdn.net/server/installers/linux/codeproject.ai-server_${VERSION}_Ubuntu_arm64.zip | direct archive download; pattern recorded |
| http://0.0.0.0:32168 | bind-address literal (not a source) |
| http://0.0.0.0:32168} | template artifact in plan.md (not a source) |

## Fetch failures

- GitHub releases: asset list did not load ("Assets 2" only). Asset names NOT confirmed; the plan's CDN names come from plan research, not from these pages.
- No other failures.

## plan.md corrections

- Section 1 Port row / Section 6: plan says "The legacy port 5000 is also opened unless `ServerOptions.DisableLegacyPort` is true" (from appsettings.json, not re-verified here). The Docker Hub page and the TrueCharts-era examples use `5000`, which conflicts with the 32168 docs. Not edited; see unverified list.
- Section 1 Upstream Dockerfile row: "only documented env var is `TZ`" -> no env var is documented on the Docker Hub page or the docs pages fetched; `TZ` is not documented in these sources. Source: codeproject-dockerhub.md, codeproject-docs-install-linux.md.
- Section 4 step 4: `dotnet-install.sh -c 9.0 --runtime aspnetcore` is valid per the script's options (`-c 9.0` = A.B channel; `--runtime aspnetcore`). Source: codeproject-dotnet-install-script.md. Not a change, but the script does NOT verify checksums (plan already says pin/mirror).

## Unverified (plan.md left as-is)

- Installer flow: docs use `sudo dpkg -i` with `dotnet-sdk-9.0` and run the server under systemd (codeproject-docs-install-linux.md). plan.md's extract-only approach (`dpkg-deb -x`, no postinst) is a choice, not contradicted.

- Docker Hub `2.9.7` tag (plan section 1). The fetched Docker Hub page shows only `latest` (`gpu` in the example) and "updated almost 2 years ago". Tag list not confirmed.
- The release notes/tag mismatch: repo releases list v2.9.5 as latest. Plan's `2.9.7` (Docker, amd64 only) is consistent with that but not re-verified.
- `DisableLegacyPort` default and whether 5000 listens inside the container (plan section 6 "omit unless confirmed").
- Module install needs internet: not stated by any source.
- Data/config paths `/etc/codeproject/ai` and `/app/modules` (confirmed by Docker Hub and TrueCharts; used by plan).
- `/usr/bin/codeproject.ai-server-<ver>/server` layout (plan) vs docs `/usr/bin/codeproject.ai-server/start.sh` (the docs' manual start path differs from the plan's extraction target).

## Notes

- Docs and Docker Hub conflict on port (32168 vs 5000) and on GPU support status (CPU-only release statement vs GPU image section).
- The docs install page mixes 2.9.1 and 2.9.5.
