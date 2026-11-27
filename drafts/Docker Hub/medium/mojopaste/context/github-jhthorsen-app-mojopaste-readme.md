# github jhthorsen/app-mojopaste README (pinned 246642c)

Source URL(s): https://raw.githubusercontent.com/jhthorsen/app-mojopaste/246642c/README.md (fetched 2026-11-27)

- Pastebin (App::mojopaste); plain text and Google prettify; optional CSV charts (morris.js)
- Install: `cpanm --sudo App::mojopaste`
- Docker run example: `docker run -d -v /var/lib/mojopaste:/app/data -p 3000:8080 jhthorsen/mojopaste`
- Daemon: `mojopaste daemon --listen http://*:8080`; `PASTE_DIR=/path mojopaste daemon ...`
- Hypnotoad: `MOJO_CONFIG=/path/to/mojopaste.conf hypnotoad $(which mojopaste)`
- Config keys: paste_dir, enable_charts (default 0), hypnotoad.listen
- Chart feature: needs Text::CSV; `PASTE_ENABLE_CHARTS=1` env or config enable_charts
