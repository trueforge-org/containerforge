# context index: vaultwarden (fetched 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/vaultwarden/values.yaml | truecharts-vaultwarden.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/vaultwarden/Chart.yaml | truecharts-vaultwarden.md |
| https://hub.docker.com/v2/repositories/library/debian/ (+ /tags?page_size=10) | dockerhub-debian.md |
| https://hub.docker.com/v2/repositories/library/rust/ (+ /tags?page_size=10) | dockerhub-rust.md |
| https://raw.githubusercontent.com/dani-garcia/vaultwarden/6ed6921cc2b0e03b4d74189574d2a5e71c512e97/docker/Dockerfile.debian | upstream-vaultwarden-dockerfile-debian.md |

Skipped: https://github.com/dani-garcia/vaultwarden/blob/...Dockerfile.debian (duplicate of raw); https://github.com/timshel/vaultwarden and its blob Dockerfile (beta fork, not built here); https://github.com/dani-garcia/vaultwarden/wiki (wiki, not fetched; config names unverified); https://github.com/dani-garcia/vaultwarden (repo page, not fetched).

Failures: none.

## plan.md corrections
- No in-place edit. Verified in the fetched Dockerfile: the full digests are `docker.io/vaultwarden/web-vault@sha256:7baaa7d5349742548b6c44e557c1512157b22010cdf314ccc399ffdcacb5eb52` and `docker.io/tonistiigi/xx@sha256:40fe21f44bb8cddf1eb1226db190d0a984118f62ee02a91b77d99448d28264a6`. plan.md (section 2 row "Upstream Dockerfile", and step 10 "full digest UNVERIFIED") still shows them truncated/UNVERIFIED; replace with these full values when writing the Dockerfile.
- Not checked: ROCKET/DATA_FOLDER/ADMIN_TOKEN config names (vaultwarden docs not fetched).
