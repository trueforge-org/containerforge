# Context: vintage-story

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/vintage-story/values.yaml + Chart.yaml | truecharts-vintage-story.md |
| https://raw.githubusercontent.com/ich777/docker-vintage-story/master/Dockerfile (github blob variant same) | ich777-docker-vintage-story.md |
| http://api.vintagestory.at/stable.json | vintagestory-stable-json.md |
| https://wiki.vintagestory.at/index.php/Server_Config | vintagestory-wiki-server-config.md |

Skipped: github repo root (duplicate), packages.ubuntu.com/resolute/dotnet-runtime-10.0 (package search page; Dockerfile uses Microsoft Debian 13 repo), www.vintagestory.at (homepage), image refs (`ich777/mono-baseimage`, `ghcr.io/ich777/vintagestory`), binary downloads (vs_server tarballs listed in stable.json, not downloaded), packages.microsoft.com deb (binary download).

Failures: none.

## plan.md corrections
- None verified. Note: chart `VS_CHANNEL` is set to a digest string (`stable@sha256:...`) rather than channel name `stable`; flagged, not edited (chart file, not plan).
