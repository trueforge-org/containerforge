# gpodder/gpodder upstream (3.11.5): setup.py, COPYING, docs

Source URL(s): https://raw.githubusercontent.com/gpodder/gpodder/3.11.5/setup.py (fetched 2026-11-27, grep only), https://raw.githubusercontent.com/gpodder/gpodder/3.11.5/COPYING (HTTP 200, not read), https://gpodder.github.io/docs (HTTP 200, nav page only)

## Build
- Python package built with setup.py; `make install` used by the container build (PREFIX/DESTDIR honoured).
- setup.py: find_data_files(uis, scripts), find_scripts(uis) (UI-dependent install); scripts and data_files passed to setup().
- Install targets depend on UI selection (gtk/cli/etc.); not fully inspected.

## Docs
- gpodder.github.io/docs: index of user manual, FAQ, platform pages, YouTube config. No install/config env facts on that page.

## License
- COPYING (GPL, version 3 header in setup.py). Not read in full.

## Gotchas
- Docs page is navigation only; no port/env data.
