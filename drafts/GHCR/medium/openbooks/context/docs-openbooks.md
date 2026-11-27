# OpenBooks docs (evan-buss.github.io/openbooks)

Source URL(s) + date:
- https://evan-buss.github.io/openbooks (2026-11-27, main page: nav only)
- https://evan-buss.github.io/openbooks/setup/docker/ (2026-11-27, follow-up)
- https://evan-buss.github.io/openbooks/configuration/ (2026-11-27, follow-up)

Docker (setup page):
- Multi-platform image published to Docker Hub per release (`evanbuss/openbooks`).
- Compose example: image `evanbuss/openbooks:latest`, ports `8080:80`, volume `~/Downloads/openbooks:/books`, `command: --persist --name`, env `BASE_PATH=/openbooks/`.
- Config passed as command flags; env BASE_PATH for base path.

Configuration (server mode flags, defaults):
| Flag | Default | Description |
| --- | --- | --- |
| --basepath | / | Web UI path, trailing slash required |
| --browser / -b | false | Open browser on startup |
| --dir / -d | /temp (per docs table, footnote) | Directory for search results and eBooks; Docker fixes it to `/books` |
| --no-browser-downloads | false | Save to disk instead of sending to browser |
| --persist | false | Keep eBook files after sending to browser |
| --port / -p | 5228 | Listen port (Dockerfile overrides to 80) |
| --rate-limit / -r | 10 | Seconds between IRC search requests (min 10) |

Global flags (both modes):
| Flag | Default |
| --debug | false |
| --log / -l | false |
| --name / -n | REQUIRED (IRC username) |
| --searchbot | search |
| --server / -s | irc.irchighway.net:6697 |
| --tls | true |
| --useragent / -u | OpenBooks v4.5.0 |

Env vars: the docs state configuration is via flags only ("There are plans to allow configuration via environment variables and config files in a future release"). Only `BASE_PATH` is documented as env (Docker setup); the Dockerfile sets `BASE_PATH=/`.

Gotchas:
- Chart sets `openbooks.user_name` (`--name`), `persist: false`, `log: true`, `debug: true`.
- Docs say the IRC name flag is REQUIRED; the Dockerfile ENTRYPOINT does not supply it, so it comes from the command.
