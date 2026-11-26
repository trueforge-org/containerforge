# Context index: factorio

Fetched 2026-11-26.

## Sources summarised

| Source URL | Summary file |
| --- | --- |
| https://github.com/factoriotools/factorio-docker | github-factoriotools-factorio-docker.md |
| https://github.com/factoriotools/factorio-docker/blob/446f2553eedb142eb6a25c670af7def2647ba24c/docker/Dockerfile | github-factoriotools-factorio-docker.md |
| https://raw.githubusercontent.com/factoriotools/factorio-docker/446f2553eedb142eb6a25c670af7def2647ba24c/docker/Dockerfile | github-factoriotools-factorio-docker.md |
| https://raw.githubusercontent.com/factoriotools/factorio-docker/446f2553eedb142eb6a25c670af7def2647ba24c/docker/files/docker-entrypoint.sh | github-factoriotools-factorio-docker.md |
| https://raw.githubusercontent.com/factoriotools/factorio-docker/446f2553eedb142eb6a25c670af7def2647ba24c/README.md | github-factoriotools-factorio-docker.md |
| https://raw.githubusercontent.com/factoriotools/factorio-docker/446f2553eedb142eb6a25c670af7def2647ba24c/LICENSE | github-factoriotools-factorio-docker.md |
| https://hub.docker.com/r/factoriotools/factorio | dockerhub-factoriotools-factorio.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/factorio | truecharts-factorio.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/factorio/values.yaml | truecharts-factorio.md |
| https://factorio.com/ | docs-factorio-com.md |
| https://factorio.com/api/latest-releases | docs-factorio-com.md |
| https://factorio.com/download/sha256sums/ | docs-factorio-com.md |
| https://wiki.factorio.com/ | docs-wiki-factorio-com.md |
| https://wiki.factorio.com/Command_line_parameters | docs-wiki-factorio-com.md (followed from main page, relevant to server flags) |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page (only the user can sign) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://factorio.com/get-download/stable/headless/linux64 | direct binary download; pattern recorded in docs-factorio-com.md |
| https://factorio.com/get-download/2.1.25/headless/linux64 | direct binary download (plan.md); pattern recorded |
| https://factorio.com/get-download/2.1.25/headless/linux-arm64 | direct binary download (plan.md); pattern recorded |
| https://www.factorio.com/get-download/<version>/headless/<platform> | direct binary download template (Dockerfile); pattern recorded |
| https://github.com/ptitSeb/box64/releases/download/v0.2.4/box64-GENERIC_ARM-RelWithDebInfo.zip | direct archive download; upstream box64 path, not used on native arm64 |
| ghcr.io/trueforge-org/ubuntu | ghcr image ref, not a web page |
| factoriotools/factorio (Docker Hub image ref) | covered by the Docker Hub page fetch |
| https://github.com/trueforge-org/truecharts (chart OCI) `oci://oci.trueforge.org/truecharts/factorio` | OCI reference, not a web page |

Linked but not followed (budget, not clearly needed for the Dockerfile): https://wiki.factorio.com/Multiplayer, https://wiki.factorio.com/Application_directory (User data directory; the write-data default is unconfirmed as a result), https://factorio.com/download (download page).

Named references without a URL, not fetched: Wube Software (vendor), Factorio Terms of Service (plan.md section 10), `pwgen`, `setpriv`.

## Fetch failures

- https://raw.githubusercontent.com/factoriotools/factorio-docker/446f2553eedb142eb6a25c670af7def2647ba24c/docker/docker-entrypoint.sh: HTTP 404. Retried at `docker/files/docker-entrypoint.sh` (from the Dockerfile `COPY files/*.sh`), which succeeded.
- https://factorio.com/download/sha256sums/ returned a long listing; the fetch truncated it, so only 2.1.25 lines and a partial version list are recorded.

## Notes
- Upstream entrypoint passes `--use-server-whitelist` as a bare flag. The wiki documents it as a BOOL.
- Factorio 2.1.25 headless is stable per factorio.com API.

## plan.md corrections

No edits made to plan.md in this run beyond the ones listed below. Nothing was changed without a clear source.

Unverified (not edited):
- plan.md section 7 `--use-server-whitelist` (bare) vs wiki's documented BOOL form `--use-server-whitelist=true`. Upstream entrypoint uses the bare form, so it is left as is (unverified which is correct for the game).
- plan.md section 1 claims Docker Hub has `2.1.25` and the `-rootless`/`stable-*` variants. The fetched Docker Hub page lists `latest` and `2.1.24`; `2.1.25` was not seen. Variant patterns confirmed.
- plan.md section 1 says factoriotools/factorio-docker is MIT. Confirmed (LICENSE, "The MIT License (MIT)", "Copyright (c) 2016").
- plan.md section 10 licence/redistribution claims: the Factorio ToS page was not fetched. Unverified.
- plan.md section 7 default write-data location (`__PATH__executable__/../..`) and `read-data=../../data`: the wiki did not confirm them. The upstream sed sets write-data to `/factorio/`. Unverified.
- plan.md section 7 `--rcon-password` via `uuidgen`: upstream uses `pwgen 15 1`. Not an error, left unchanged.
- plan.md section 4 `ARG VERSION`: upstream Dockerfile uses `SHA256` as a required ARG too; the plan fetches checksums from the sha256sums page instead. Design choice, not a fact error.
