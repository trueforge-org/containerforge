# ffmpeg.org

Source URL(s) + fetch date:
- https://ffmpeg.org and https://ffmpeg.org/ (fetched 2026-11-26)
- https://ffmpeg.org/documentation.html (fetched 2026-11-26)

## What it is

FFmpeg: multimedia framework (libav* libraries and ffmpeg/ffprobe/ffplay CLIs).

## Version/release info

- Newest stable release on the home page: FFmpeg 8.1 "Hoare", posted 2026-03-16. Download anchors: `download.html#release_8.1`, `#release_8.0`, `#release_7.1`.
- Sources: `download.html#get-sources`. Git: `https://git.ffmpeg.org/gitweb?p=ffmpeg.git;a=summary`. Changelog: gitweb `refs/heads/release/<X.Y>:/Changelog`.
- Documentation page: newest Doxygen branch listed is 9.0 (trunk docs also exist). It does not label a stable version.

## License

- Home page and docs page do not state GPL vs LGPL; the "Legal" page (`legal.html`) is the place to check (not fetched).

## Documentation links (for CLI and build questions)

- CLI: `ffmpeg.html`, `ffprobe.html`, `ffplay.html` (and `*-all.html` variants).
- Components: `ffmpeg-codecs.html`, `ffmpeg-filters.html`, `ffmpeg-formats.html`, `ffmpeg-protocols.html`, `ffmpeg-utils.html`, etc.
- FAQ: `faq.html`; supported external libraries/codecs: `general.html`; platform: `platform.html`.
- Wiki: https://trac.ffmpeg.org/wiki

## Relevance to this app

- Ubuntu 26.04 package `ffmpeg` (apt) is what the container uses, not upstream source. The upstream 8.1 release is newer than the plan's apt pin (`7:8.0.1-3ubuntu2`); that is a distro version, not a conflict.
- The DTS to AC3 path needs `ac3` encoder and `dca` decoder in the build (plan notes UNVERIFIED; not checked here).
