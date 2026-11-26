# Context: zoneminder

| Source URL | File |
| --- | --- |
| https://github.com/ZoneMinder/zoneminder | zoneminder-readme-docs-repo.md |
| https://github.com/dlandon/zoneminder.unraid/blob/ee9d87e8d1a6e539206f6412109593847eae2d84/Dockerfile | dlandon-zoneminder-unraid-dockerfile.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/zoneminder | dockerhub-and-truecharts-chart.md |
| https://hub.docker.com/r/dlandon/zoneminder.unraid | dockerhub-and-truecharts-chart.md |
| https://zmrepo.zoneminder.com | zoneminder-readme-docs-repo.md |
| https://zmrepo.zoneminder.com/debian/release-1.38/resolute | zoneminder-readme-docs-repo.md |
| https://zoneminder.com | FAILED (403 Cloudflare challenge; alternative http://zoneminder.com also 403) |
| https://zoneminder.readthedocs.io | zoneminder-readme-docs-repo.md |

Skipped categories: none (urls.txt pre-filtered).

Failures:
- https://zoneminder.com: 403 (one alternative, http://zoneminder.com: 403).

## plan.md corrections
- L14 "Real package source": replaced "Versions seen were 1.38.2 and 1.38.3+resolute1; 1.38.6 availability there is UNVERIFIED" with the resolute index contents (1.38.2, 1.38.3+resolute1, 1.38.5+resolute1, 1.38.6+resolute1, amd64 and arm64). Source: zmrepo resolute directory listing.
- L15 "Per-arch downloads": arm64 is now confirmed present in the resolute index (`zoneminder_1.38.6+resolute1_arm64.deb`). Source: same listing.
- Unverified conflicts (not edited):
  - plan L17 says the dlandon Dockerfile is "unreachable"; the raw Dockerfile at ee9d87e fetched fine (phusion jammy, PHP 8.4, PPA, tailscale, EXPOSE 80 443 9000). Plan's description of it is otherwise consistent.
  - plan L13 / L41 repo key line not verified here.
