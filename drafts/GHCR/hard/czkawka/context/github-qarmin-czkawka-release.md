# qarmin/czkawka latest release (GitHub API)

Source URL(s) + date: https://api.github.com/repos/qarmin/czkawka/releases/latest, fetched 2026-11-27.

## Release
- tag_name `12.0.2` (no `v` prefix), published 2026-09-09T19:48:14Z.

## Linux assets (sha256 from API digest)
| Asset | sha256 |
| --- | --- |
| linux_czkawka_cli_x86_64 | 61e7e8ac3f42338957ddc0739df653b9df6ff2958cab3b4cce14663b39c40843 |
| linux_czkawka_cli_arm64 | 3a65408ca30036cf1cd993112bde6288e13c870842d12131dee8b4e435325c38 |
| linux_czkawka_cli_heif_raw_avif_x86_64 | b62cf139ba6e0331e4a279d75d0caf5bfa81f16c645fdf0008dc7a830573e05f |
| linux_czkawka_cli_heif_raw_avif_arm64 | 6ca6ec65029c3d5ed87ade0690508fcf9566f0bdbb1b480a773499a3a5041022 |
| linux_czkawka_cli_musl | e90381d8c38479a97f9e98335523208ac285b6e4bcac10f41db791d04a51b14a |
| linux_czkawka_gui_x86_64 | cb97a6a0668f0d33087fc4a5d28da15a29de2ea91861db18755176fb65810072 |
| linux_czkawka_gui_arm64 | f5d162c85646409c34cbd95391530bf3f044e93250ad222242944067aec289c5 |
| linux_czkawka_gui_heif_raw_avif_x86_64 | 96a2fee3fbc5ce075b5e96c9c6b8a03ddae6fdf966aa1bd116c99b6f7590e34c |
| linux_czkawka_gui_heif_raw_avif_arm64 | f596c672b0e0ae8d32256b9a6e7d46a6e6e8f302090b2845f9ff49171a028501 |
| linux_krokiet_* (zip and binaries) | many variants, not used by this app |

- Other assets: deps_linux.sh, deps_macos.sh, deps_windows.bat, mac_*, windows_*, cedinia.apk.
- Asset naming: `linux_<app>_<variant>_<arch>`; arch suffix `x86_64` or `arm64`.
- Download base: https://github.com/qarmin/czkawka/releases/download/12.0.2/<asset>.

## Gotchas
- Digests are published by the API (sha256:...), so pin these rather than trust-on-first-use.
- Release body (API `body` field): "Version 12.0 is the last released version of Czkawka GTK" - no new GTK binaries; migrate to Krokiet (Slint).
