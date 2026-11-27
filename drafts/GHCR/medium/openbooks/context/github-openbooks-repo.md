# Upstream: evan-buss/openbooks (repo, README, latest release)

Source URL(s) + date:
- https://github.com/evan-buss/openbooks (not fetched directly; README used)
- https://raw.githubusercontent.com/evan-buss/openbooks/master/README.md (2026-11-27)
- https://api.github.com/repos/evan-buss/openbooks/releases/latest: 403. Alternative https://github.com/evan-buss/openbooks/releases/latest (HTML) -> "Release v4.5.0"
- https://api.github.com/repos/evan-buss/openbooks/license: 403. Alternative https://raw.githubusercontent.com/evan-buss/openbooks/master/LICENSE -> "MIT License, Copyright (c) 2021 Evan Buss" (2026-11-27)

What it is: OpenBooks, a tool that searches and downloads eBooks from IRC Highway (irc.irchighway.net). Two modes: Server (web UI) and CLI (terminal).

Version: latest release `v4.5.0` (HTML, 2026-11-27). Note: the README says only the latest release is supported.

Install/run (README):
- Binary: `./openbooks --help`, Linux `chmod +x`
- Docker: `docker run -p 8080:80 evanbuss/openbooks`
- Persist: `docker run -p 8080:80 -v /path:/books evanbuss/openbooks --persist`
- Base path: `docker run -p 8080:80 -e BASE_PATH=/openbooks/ evanbuss/openbooks` or `./openbooks server --basepath /openbooks/`

Build from source: `cd server/app && npm install`; Go build; mock IRC server in `cmd/mock_server`.

License: MIT (LICENSE file, Copyright (c) 2021 Evan Buss).

Gotchas: README docker run example uses `evanbuss/openbooks` (Docker Hub), while the chart uses `ghcr.io/evan-buss/openbooks`.
