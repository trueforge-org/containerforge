# Context sources: plex-playlist-sync

| Source URL | Summary file |
| --- | --- |
| https://github.com/rnagabhyrava/plex-playlist-sync | github-rnagabhyrava-plex-playlist-sync.md |
| https://raw.githubusercontent.com/rnagabhyrava/plex-playlist-sync/v1.0.2/Dockerfile (draft blob `c3333a5...`) | github-rnagabhyrava-plex-playlist-sync.md (tag v1.0.2 read instead) |
| https://raw.githubusercontent.com/rnagabhyrava/plex-playlist-sync/v1.0.2/README.md | github-rnagabhyrava-plex-playlist-sync.md |
| https://raw.githubusercontent.com/rnagabhyrava/plex-playlist-sync/v1.0.2/plex-playlist-sync/run.py | github-rnagabhyrava-plex-playlist-sync.md |
| https://raw.githubusercontent.com/rnagabhyrava/plex-playlist-sync/v1.0.2/plex-playlist-sync/utils/plex.py | github-rnagabhyrava-plex-playlist-sync.md |
| https://raw.githubusercontent.com/rnagabhyrava/plex-playlist-sync/v1.0.2/requirements.txt | github-rnagabhyrava-plex-playlist-sync.md |
| https://raw.githubusercontent.com/rnagabhyrava/plex-playlist-sync/v1.0.2/LICENSE.md | github-rnagabhyrava-plex-playlist-sync.md |
| https://github.com/rnagabhyrava/plex-playlist-sync/releases/tag/v1.0.2 | github-rnagabhyrava-plex-playlist-sync.md (via API) |
| https://api.github.com/repos/rnagabhyrava/plex-playlist-sync/releases/tags/v1.0.2 | github-rnagabhyrava-plex-playlist-sync.md |
| https://api.github.com/repos/rnagabhyrava/plex-playlist-sync | github-rnagabhyrava-plex-playlist-sync.md (archive status) |
| https://hub.docker.com/r/rnagabhyrava/plexplaylistsync | dockerhub-rnagabhyrava-plexplaylistsync.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/plex-playlist-sync | truecharts-plex-playlist-sync.md |

## Skipped URLs

- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu (containerforge `apps/<base>` link)
- https://github.com/trueforge-org/containerforge/tree/main/apps/python (containerforge `apps/<base>` link)
- https://cla-assistant.io/trueforge-org/containerforge (CLA link; noted for reference)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json (forgetool schema URL)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json (forgetool schema URL)
- ghcr.io/trueforge-org/python:3.15.2@sha256:... and ghcr.io/trueforge-org/ubuntu (image refs, not web pages)
- docker.io/rnagabhyrava/plexplaylistsync:latest (image ref; covered by the Docker Hub and chart entries)
- https://github.com/rnagabhyrava/plex-playlist-sync/blob/HEAD/requirements.txt (draft/plan link to HEAD; tag v1.0.2 requirements read instead)
- https://github.com/rnagabhyrava/plex-playlist-sync/archive/refs/tags/v1.0.2.tar.gz (source archive; direct archive download, pattern recorded)

## Fetch failures

- None.

## plan.md corrections

- Section 1, requirements row: `plexapi==4.11.2` -> `plexapi>=4.7.0`. Source: `github-rnagabhyrava-plex-playlist-sync.md` (`requirements.txt` at tag v1.0.2 is `plexapi>=4.7.0`; the file has no exact pin).
- Section 4, last paragraph: `plexapi==4.11.2` is an exact pin from 2022 -> `plexapi>=4.7.0` is a lower bound only. Same source.
- Section 10, archived line: "Repo archived since the last commit in 2022" -> "Repo archived (GitHub API `archived: true`, `pushed_at` 2023-12-15)". Same source (API).
- Plan's `plexapi==4.11.2` mention in section 10 also updated to the lower-bound wording. Same source.

## Unverified (not edited)

- Section 1: plan says `main` has one later commit (2022-08-14). The API `pushed_at` is 2023-12-15, which does not confirm that date; main's commit list was not fetched.
- Section 1 and 6: plan lists `APPEND_SERVICE_SUFFIX` as read by `run.py`. Not in the fetched `run.py` reads, and `utils/plex.py` reads no env. The chart templates it. Left in the plan; unverified where it is read.
- Section 1: `APPEND_INSTEAD_OF_SYNC` `"1"` = true (append). Matches the code, but the README comment says `1 = Sync tracks, 0 = Append only`. Plan keeps the code meaning.
- Section 1, data path row: `mkdir(parents=True)` is only in `_write_csv`; `_delete_csv` does not create directories. The plan's wording is ambiguous, not wrong.
- Section 4: `rmdir /data` assumes the ubuntu base creates `/data` as a directory. Not checked against the base image.
- Section 5 and 10: license variant. `LICENSE.md` is the GPLv3 text; the "or any later version" wording appears only in the sample notice, so `GPL-3.0-only` vs `-or-later` remains unresolved. The GitHub API gives `GPL-3.0`.
- Section 3/10: Python 3.15 compatibility of the dependencies is not checked.
- Section 8: the runner strings were not run.
