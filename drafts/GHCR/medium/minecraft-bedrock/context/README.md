# context README: GHCR/medium/minecraft-bedrock

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/minecraft-bedrock/values.yaml | truecharts-minecraft-bedrock.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/minecraft-bedrock/Chart.yaml | truecharts-minecraft-bedrock.md |
| https://raw.githubusercontent.com/itzg/docker-minecraft-bedrock-server/master/Dockerfile | github-itzg-docker-minecraft-bedrock-server.md |
| https://raw.githubusercontent.com/itzg/docker-minecraft-bedrock-server/master/bedrock-entry.sh | github-itzg-docker-minecraft-bedrock-server.md |
| https://raw.githubusercontent.com/itzg/docker-minecraft-bedrock-server/master/demoter-entry.sh | github-itzg-docker-minecraft-bedrock-server.md |
| https://raw.githubusercontent.com/itzg/docker-minecraft-bedrock-server/master/README.md | github-itzg-docker-minecraft-bedrock-server.md |
| https://raw.githubusercontent.com/itzg/docker-minecraft-bedrock-server/master/LICENSE | github-itzg-docker-minecraft-bedrock-server.md |
| https://net.web.minecraft-services.net/api/v1.0/download/links | api-minecraft-services-download-links.md |
| https://raw.githubusercontent.com/kittizz/bedrock-server-downloads/refs/heads/main/bedrock-server-downloads.json | github-kittizz-bedrock-server-downloads.md |
| https://learn.microsoft.com/en-us/minecraft/creator/documents/bedrockserver/getting-started | skipped (see below) |

Skipped categories: GitHub HTML pages (blob Dockerfile variant, repo root, docker-minecraft-server repo), image-ref/EULA-only pages, Microsoft Learn page (fetched, general getting-started HTML, no build facts beyond what is in the scripts; not summarised), itzg/docker-minecraft-server (Java sibling, not used), minecraft.net EULA page (fetch failed, see below).

Failures:
- https://api.github.com/repos/itzg/docker-minecraft-bedrock-server/releases/latest (403, rate limit); not retried.
- https://www.minecraft.net/en-us/download/server/bedrock (HTTP/2 INTERNAL_ERROR, then TLS EOF on HTTP/1.1 retry); not retried further.
- https://www.minecraft.net/en-us/eula (HTTP/2 INTERNAL_ERROR); not retried.

## plan.md corrections
- None.
