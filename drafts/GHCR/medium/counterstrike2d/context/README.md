# Context index: counterstrike2d

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/counterstrike2d/values.yaml | truecharts-counterstrike2d.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/counterstrike2d/Chart.yaml | truecharts-counterstrike2d.md |
| https://api.github.com/repos/ich777/docker-cs2d-server | upstream-ich777-docker-cs2d-server.md (repo metadata) |
| https://github.com/ich777/docker-cs2d-server/blob/master/Dockerfile | upstream-ich777-docker-cs2d-server.md |
| https://raw.githubusercontent.com/ich777/docker-cs2d-server/master/Dockerfile | upstream-ich777-docker-cs2d-server.md |
| https://raw.githubusercontent.com/ich777/docker-cs2d-server/master/scripts/start.sh | upstream-ich777-docker-cs2d-server.md |
| https://raw.githubusercontent.com/ich777/docker-cs2d-server/master/scripts/start-server.sh | upstream-ich777-docker-cs2d-server.md |
| https://www.cs2d.com/download.php | vendor-cs2d-download.md |

Skipped categories: https://www.cs2d.com (home page, covered by the download page), https://www.steampowered.com (marketing root, no build info). Not fetched.

Failures: none.

Cache: no hits for this app (ich777 steamcmd cache is for a different repo).

## plan.md corrections
- Line 14 (Checksum source): "None published (vendor page, upstream repo)" -> vendor publishes Dedicated CRC32 and SHA256 hash values for Linux x64, Linux ARM64 and Windows on https://www.cs2d.com/download.php (source: vendor-cs2d-download.md). Values behind links not fetched.
- Line 53 (CS2D_SHA256 step): "(UNVERIFIED: no vendor checksum)" -> points to the vendor SHA256 values to cross-check (source: vendor-cs2d-download.md).
- Line 209 (Gotchas): "No vendor checksum" -> vendor SHA256 cross-check note (source: vendor-cs2d-download.md).

Unverified conflicts (not edited):
- Ports: plan says the draft's 36963 is tcp and udp (inferred). TrueCharts values.yaml declares UDP 36963 only, no tcp (truecharts-counterstrike2d.md). Confirm before listing tcp.
- Download URL: plan line 12 says the dedicated zip is linked from the vendor page. The extract had no hrefs, so the link target was not confirmed (vendor-cs2d-download.md). The upstream script's http:// path is the same file.
- Plan line 17 wording "upstream start-server.sh" still stands: the ich777 start-server.sh was fetched and matches (launch via cs2d_dedicated, malformed wget -O line in FORCE_UPDATE).
