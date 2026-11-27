# GitHub: LMS-Community/slimserver README

Source URL(s), fetched 2026-11-27:
- https://github.com/LMS-Community/slimserver (fetched as raw README: https://raw.githubusercontent.com/LMS-Community/slimserver/master/README.md)

## What it is
- Server software for Logitech/Squeezebox players plus emulators (Squeezelite, SqueezePlay).
- Former names: Logitech Mediaserver, SlimServer, SqueezeCenter, SqueezeboxServer, SliMP3.
- Streams a local music library; plugins add music services and internet radio.
- Written in Perl.

## Platforms
- Linux, macOS, Solaris, Windows (anything Perl runs on). Raspberry Pi, NAS listed.

## Build/run requirements
- Perl version: not stated.
- Dependencies: not stated.
- Install steps deferred to https://lyrion.org/getting-started/ (not in this README).

## Ports
- Not stated in this README. (HTTP 9000, CLI 9090, slimproto 3483 are not present here.)

## License
- Not stated in this README.

## Docker
- Badges only: Docker Hub `lmscommunity/lyrionmusicserver`; GHCR `lyrionmusicserver`. No usage instructions.

## Other
- Contribution workflow: fork, feature branch, PR. Issues tagged bug/enhancement.
- CI: GitHub Actions smoketest workflow (00_smoketest.yaml).
