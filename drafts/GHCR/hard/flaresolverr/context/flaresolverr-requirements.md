# FlareSolverr requirements.txt

Source URL: https://raw.githubusercontent.com/FlareSolverr/FlareSolverr/HEAD/requirements.txt (branch HEAD, fetched 2026-11-27; not pinned to the v3.5.2 tag)

## Pins
| Package | Version | Note |
| --- | --- | --- |
| bottle | 0.13.4 | |
| waitress | 3.0.2 | |
| selenium | 4.51.0 | |
| func-timeout | 4.3.5 | |
| prometheus-client | 0.26.0 | |
| requests | 2.34.2 | required by undetected_chromedriver (per comment) |
| certifi | 2026.10.23 | |
| websockets | 17.3 | |
| packaging | 26.3 | |
| xvfbwrapper | 0.2.37 | only when platform_system != "Windows" |
| pefile | 2024.8.26 | only when platform_system == "Windows" |

## Gotchas
- `undetected-chromedriver` is not listed as its own line.
- Fetched from HEAD, not the v3.5.2 tag; the tagged file may differ.
