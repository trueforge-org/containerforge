# openaudible.org/documentation

Source URL(s): https://openaudible.org/documentation · fetched 2026-11-26

- Requirements: no Java mention. FFmpeg (LGPL) used for conversion. Internet needed.
- Transcription: speech model 75 MB–1.6 GB; GPU optional (Linux CPU only).
- Built-in web server: default port 8000, bound 127.0.0.1, password required.
- Concurrency defaults: 3 downloads, 3 conversions.
- Config/data dirs: Linux `~/OpenAudible` (prefs, logs, temp); override with env `OPENAUDIBLE_HOME`. Log `OpenAudible/tmp/log.txt`.
- Library dir set via File > Manage Libraries (books.json, books, AAX/art files); relocatable.
- Linux install commands on page are apt/Debian-style; no distro matrix.
