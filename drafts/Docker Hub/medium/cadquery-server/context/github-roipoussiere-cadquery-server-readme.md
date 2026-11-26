# roipoussiere/cadquery-server README

Source: https://raw.githubusercontent.com/roipoussiere/cadquery-server/master/README.md (fetched 2026-11-26)

## What it is
- Web server rendering 3D models from CadQuery scripts in the browser; can build a static showcase site
- Status: NO LONGER ACTIVELY SUPPORTED; author invites maintainers; points to vscode OCP CAD viewer as alternative
- Rendering via three-cad-viewer; live reload, file watcher, multi-file

## Install
- `pip install cadquery-server` (CadQuery already present)
- `pip install 'cadquery-server[cadquery]'` (bundles CadQuery)
- From source: `pip install .` or `pip install '.[cadquery]'`
- Docker: `docker pull cadquery/cadquery-server`
- conda: none

## Run
- Docker: `docker run -p 5000:5000 -v $(pwd)/examples:/data cadquery/cadquery-server`
- CLI `cq-server` subcommands: `run`, `build`, `info`
- `run` flags: `-p/--port`, `-r/--raise`, `-d/--dead` (disables live reload); target default "."
- `build` flags: `-f/--format` (html, json, step, stl, svg, png, pdf, ...), `-m/--minify`
- Global: `-h`, `-V`

## Endpoints
- `/` viewer; `/json` threejs JSON; `/html` static page; `?m=<module>` selects module in folder target

## Ports / Volumes / Env
- Port 5000 (`-p`)
- /data holds scripts
- Env vars: none documented

## Script API
- `from cq_server.ui import ui, show_object`; `show_object(name, options)` (alpha, color); `debug`

## Dependencies
- Python + CadQuery (extra `[cadquery]`); three-cad-viewer

## License
- MIT

## Version naming
- no scheme stated (demo title mentions "cq-server_v-0-3-1")
