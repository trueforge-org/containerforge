# context/ for traktarr

Fetched 2026-11-26.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/l3uddz/traktarr (docker/Dockerfile @52d7196, requirements.txt and traktarr.py @1.2.5, README on master) | github-l3uddz-traktarr.md |
| https://hub.docker.com/r/eafxx/traktarr | dockerhub-eafxx-traktarr.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/traktarr (values.yaml) | truecharts-traktarr.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page, not a source.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL.
- https://github.com/trueforge-org/containerforge/tree/main/apps/python and .../apps/ubuntu: containerforge base links (apps/python is referenced in the draft; not fetched).
- https://github.com/l3uddz/traktarr/archive/refs/tags/${VERSION}.tar.gz and https://github.com/l3uddz/traktarr/archive/refs/heads/master.zip: direct source archives (pattern recorded in the GitHub summary).
- https://github.com/l3uddz/traktarr/blob/52d71964a2cd6504adda6e2b2d5cdfc68cc794c8/docker/Dockerfile: fetched raw instead.
- https://github.com/l3uddz/traktarr/blob/HEAD/requirements.txt: fetched raw at tag 1.2.5 instead (the draft's HEAD reference is not pinned).
- Local reference `docs/project-fireball.md` is not a web source.

## Fetch failures

- `misc/config.py` (first-run default config and exit behaviour): not fetched; not a listed URL, so not followed (within the 5-page budget it is the one file that would confirm the plan's exit-0 claim). Unverified.
- No other failures.

## plan.md corrections

None made. Items left as unverified (not edited):
- Plan section 1: first run on a missing config "writes a default config.json and exits 0". The README confirms that `traktarr run` generates `config.json`, and the eafxx page says the container exits after creating it. The exit code (0) is unverified (`misc/config.py` not fetched).
- Plan section 1 / 10: `attrdict==2.0.0` fails to import on Python 3.10+ because of `collections.Mapping`. Not checked in the fetched sources.
- Plan section 10: `trakt_authentication` command name under click 7+. Not checked.
- Plan section 1: "the draft's HEAD commit 52d71964 is 2023-03-14 and newer than the tag". Not checked; the commit date is not in the fetched files.
