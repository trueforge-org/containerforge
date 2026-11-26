# hub.docker.com/r/schollz/cowyo (JSON API + HTML)

Sources: https://hub.docker.com/v2/repositories/schollz/cowyo/ ; https://hub.docker.com/v2/repositories/schollz/cowyo/tags?page_size=10 ; https://hub.docker.com/r/schollz/cowyo (fetched 2026-11-26)

## Repo (JSON)
- namespace schollz; name cowyo; not private
- description: "A powerful notepad supporting listifying, encryption, self-destructing messages, and versioning."
- pull_count 126141; star_count 1; last_updated 2020-09-16 (stale)

## Tags (JSON, page_size=10)
| Tag | last_updated | full_size | arch |
| --- | --- | --- | --- |
| latest | 2020-05-14 | 11670069 | linux/amd64 |
| deps | 2020-09-16 | 12422233 | linux/amd64 |
| v3 | 2017-11-04 | 3948736 | linux/amd64 |

## HTML page extras
- Run: `docker run -d -v /directory/to/data:/data -p 8050:8050 schollz/cowyo`
- Port 8050 (HTML page example; upstream EXPOSE 8001); volume /data; env none
- Flags: -port, -host, --cert/--key, -lock, -default-page, -css, -diary
- License MIT
- Image has only linux/amd64 tags listed (no arm64)
