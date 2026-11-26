# factorio.com (game publisher site): home, API, checksums

Source URL(s) + fetch date:
- https://factorio.com/ (home)
- https://factorio.com/api/latest-releases
- https://factorio.com/download/sha256sums/
- Fetched 2026-11-26

## Home page
- Factorio is the game. Current version shown: Stable 2.1.25 and Experimental 2.1.25.
- Download page is https://factorio.com/download (releases and demo). Buy pages: /buy, /space-age/buy.
- No dedicated server link on the home page. The only download destination is /download.

## API: latest-releases
- Stable headless: `2.1.25`. Experimental headless: `2.1.25`.
- JSON shape consistent with plan.md: `{"stable":{"headless":"2.1.25"}, ...}`.
- Contains no download URL fields.

## Checksums: sha256sums
- Plain text, format `<64-hex sha256>  <filename>` (two spaces). Truncated at fetch; older 2.0.x entries not read.
- Newest version listed: 2.1.25.
- Headless file names:
  - Full: `factorio-headless_linux_<version>.tar.xz` and `factorio-headless_linux-arm64_<version>.tar.xz`.
  - Update packages: `core_expansion-linux_headless64-<from>-<to>-update.zip` and `core_expansion-linux_headless-arm64-<from>-<to>-update.zip`.
- 2.1.25 headless entries:
  - linux64: `78da2f5aa99e9e0af7586d6bf82c04aae91165d53036720dabb26e855688f3ae  factorio-headless_linux_2.1.25.tar.xz`
  - linux-arm64: `c10ab4008043713b6e37097850c69ff675acac7ab965e87d768ce46d0c1753fd  factorio-headless_linux-arm64_2.1.25.tar.xz`
- arm64 headless builds appear from about 2.1.18-2.1.19; earlier versions list linux64 only.
- Matches the checksums recorded in plan.md section 1 for 2.1.25.

## Gotchas
- Download itself is `https://factorio.com/get-download/<version>/headless/<linux64|linux-arm64>` (302 redirect to dl.factorio.com). That is a binary download and was not fetched; see README.md skipped list.
