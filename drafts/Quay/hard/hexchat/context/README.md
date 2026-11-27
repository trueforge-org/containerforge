# Context: Quay/hard/hexchat

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hexchat/values.yaml + Chart.yaml | truecharts-hexchat.md |
| https://hub.docker.com/v2/repositories/binhex/arch-hexchat/ and /tags?page_size=10 (via registry.hub.docker.com) | dockerhub-binhex-arch-hexchat.md |
| https://raw.githubusercontent.com/binhex/arch-hexchat/2c35dde8.../Dockerfile (blob variant) | binhex-arch-hexchat-dockerfile.md |
| https://github.com/binhex/documentation ; raw docker/faq/general.md | binhex-documentation-docker-faq.md |
| https://github.com/hexchat/hexchat ; raw COPYING | hexchat-repo-and-docs.md |
| https://github.com/hexchat/hexchat/releases/tag/v2.16.2 | hexchat-release-v2.16.2.md |
| https://api.github.com/... (not in list; release API call for hexchat/hexchat/releases/latest failed) | n/a |
| https://hexchat.github.io | hexchat-repo-and-docs.md |
| https://hexchat.readthedocs.io | hexchat-repo-and-docs.md |
| https://packages.ubuntu.com/resolute/hexchat ; /resolute/arm64/hexchat/download | packages-ubuntu-hexchat.md |

Note: the list had no api.github.com URL for hexchat; the release call was my own added lookup. Recorded here as a failure.

Skipped categories: none other than the binary download (ubuntu .deb is recorded by name and hash, not downloaded). The binhex/arch-hexchat blob URL and its raw variant were treated as one source.

## Failures
- https://api.github.com/repos/hexchat/hexchat/releases/latest: no tag_name returned (one attempt; the release tag page was used as the alternative).

## plan.md corrections
- None made. Notes: Docker Hub description for binhex/arch-hexchat says "Teamspeak" (stale upstream metadata).
