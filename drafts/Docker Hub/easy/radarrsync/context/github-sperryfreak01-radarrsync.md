# Sperryfreak01/RadarrSync (GitHub, original project; the draft's source)

Source URL(s) + fetch date (2026-11-26):
- https://github.com/Sperryfreak01/RadarrSync (repo, not fetched as a page; README not fetched)
- https://raw.githubusercontent.com/Sperryfreak01/RadarrSync/HEAD/requirements.txt (fetched)
- https://github.com/Sperryfreak01/RadarrSync/releases/tag/v1.0 (fetched)
- Not used: https://github.com/Sperryfreak01/RadarrSync/blob/HEAD/requirements.txt (fetched as raw instead)

## What it is
Original RadarrSync project by Sperryfreak01. Per plan.md it reads a `Config.txt` file, unlike the dairefinn fork which reads environment variables. The Docker image in this draft is built from the dairefinn fork (see github-dairefinn-radarrsync.md).

## Python deps (requirements.txt, HEAD)
- `requests==2.20.0`
- `configparser==3.5.0`

## Release v1.0
- Title "Initial release", tag v1.0, commit 2aed70b, released 10 Sep (year not shown), marked Latest, made by Sperryfreak01. Notes say only "v1.0" and "Update issue templates". Release page reports 2 assets; names did not render.
- Per plan.md the repo also has tags v1.2.1 and v1.2; the v1.0 tag has no license file.

## Gotchas
- The draft's `releases/tag/v1.0` is an upstream release tag, not the Docker image's source. Do not use it as the build source for this app.
- No license found (per plan.md).
