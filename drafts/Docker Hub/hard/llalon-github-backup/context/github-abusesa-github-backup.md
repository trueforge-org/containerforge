# abusesa/github-backup

Source URL(s): https://github.com/abusesa/github-backup. Fetched 2026-11-26.

## What
- `backup.py`: clones every GitHub repo the token can reach into `directory`; later runs refresh clones and add new repos.
- MIT. Default branch `master`. ~80 stars.

## Repo files
- `images/`, `.gitignore`, `LICENSE`, `README.md`, `backup.py`, `config.json.example`, `requirements.txt`, `setup.cfg`
- NO Dockerfile, no compose, no docker docs in repo.

## Install / run
- `pip3 install -r requirements.txt` (contents not shown). Git is implied (clones) but not named; curl/jq not mentioned.
- Run: `python3 backup.py config.json` (single positional arg = config path). No other flags documented.

## Config (JSON)
| Key | Required | Notes |
| --- | --- | --- |
| token | yes | GitHub PAT |
| directory | yes | destination, e.g. `~/backups/github.com` |
| owners | no | list of users/orgs; omitted = all repos token can read |

## Token scopes
- `repo` (public + private) or `public_repo` (public only).

## Env / ports / volumes
- Env vars: none documented. Ports: none. Volumes: none documented (output path from config).
- Config holds secret token; keep private.
