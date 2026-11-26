# hub.docker.com/r/shneezin/breitbandmessung-node

Source: https://hub.docker.com/r/shneezin/breitbandmessung-node (fetched 2026-11-26)

- Tags: `latest` (digest sha256:80922b8fa..., 207.6 MB); `debian` variant in usage
- 50K+ pulls; last updated ~3 years before fetch
- Run (Alpine): `docker run -d -v $PWD/config/:/usr/src/app/config:rw -v $PWD/messprotokolle:/export/ --name breitbandmessung shneezin/breitbandmessung-node`
- config/config.cfg: timezone=Europe/Berlin (default UTC); crontab="0 */2 * * *"; run_once; run_on_startup
- Ports: none; env: none
- Arch: Debian amd64/arm64/arm/v7; Alpine amd64/arm64
- merge.sh combines CSVs
- License note: free to use and modify; no liability

## Docker Hub JSON (added 2026-11-26)
- Source: https://hub.docker.com/v2/repositories/shneezin/breitbandmessung-node/ and /tags?page_size=10
- pull_count 51702; star_count 0; last_updated 2023-11-11 (stale); description "Perform breitbandmessung.de speedtests in an automated way"
- Tag `4cd4038a826b01ff433534f36f6a130fb7ac9635` exists (linux/amd64, arm64, arm/v7; 425 MB), matching plan's pinned commit SHA
- Other tags: latest (2023-11-11, amd64/arm64), debian (multi-arch incl. arm/v7), alpine, fd509805..., a30f6c13..., 2478778a..., d02a4975..., 37062e05..., test (2022, arm/v7). 24 tags total.
