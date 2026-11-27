# Docker Hub: knex666/prpdf

Source URL(s):
- https://hub.docker.com/v2/repositories/knex666/prpdf/
- https://hub.docker.com/v2/repositories/knex666/prpdf/tags?page_size=10
Fetched: 2026-11-27

## Repository
| Key | Value |
| --- | --- |
| pull_count | 32784 |
| star_count | 0 |
| last_updated | 2026-09-06 |
| description | Preview and Rename Scanned PDF Documents. Autoscan and sort with OCR. Merge |
| storage_size | 15821390037 bytes |

## Tags (count 2)
| Tag | Arch | Digest | Last pushed |
| --- | --- | --- | --- |
| latest | amd64 | sha256:50964b7d20ea98e588b488119c840bdf2244c0cf02c185c99be4c0cf9dbdb968 | 2026-09-06 |
| latest-dev | amd64 | same digest as latest | 2026-09-06 |

## Run (from full_description)
- `docker run -d --name='PRPDF' -p 80:80 -v '/mnt/user/Share':'/Archiv/':'rw' -v '/mnt/user/SCAN':'/source/static/pdf/':'rw' -v '/mnt/user/appdata/prpdf/':'/source/config':'rw' 'knex666/prpdf' python3 /source/prpdf.py`
- Sub-folders under /Archiv/ can be mounted separately for a custom virtual folder layout.

## config.json (documented keys)
| Key | Example | Meaning |
| --- | --- | --- |
| port | 80 | web port |
| debug | "off" | "on" shows OCR results during autoscan |
| lang | "deu" | OCR language |
| updatetime | 1800 | autoscan interval (seconds) |
- Example config lives at https://github.com/maschhoff/prpdf/blob/main/config/config.json (not fetched).

## Gotchas
- README says run command overrides CMD with `python3 /source/prpdf.py`; Dockerfile default CMD is `flask run` (see github-prpdf-dockerfile.md).
- Description says BETA.
