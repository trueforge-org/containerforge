# dot.net/v1/dotnet-install.sh

Source URL(s): https://dot.net/v1/dotnet-install.sh (301 -> https://builds.dotnet.microsoft.com/dotnet/scripts/v1/dotnet-install.sh; redirect followed once)
Date: fetched 2026-11-26

## What it is
- Official .NET Foundation install script (MIT). Installs .NET SDK or shared runtime on Linux/macOS/FreeBSD. CI-oriented. Needs curl or wget.
- NOTE: FeedCord Dockerfile does NOT use this script; it uses `mcr.microsoft.com/dotnet/sdk:9.0` and `aspnet:9.0` base images.

## Flags
| Flag | Meaning |
| --- | --- |
| `-c, --channel` | LTS (default), STS, `A.B`, or `A.B.Cxx` band; `Current` deprecated -> STS |
| `-v, --version` | `latest` (default) or exact build; overrides channel |
| `-i, --install-dir` | target dir |
| `--runtime` | `dotnet` or `aspnetcore` (runtime only, no SDK) |
| `--arch` | x64, arm, arm64, s390x, ppc64le, loongarch64 (auto from uname -m) |
| `--os` | osx/macos, linux, linux-musl, freebsd, rhel.6 |
| `-q, --quality` | daily, preview, ga (ignored for LTS/STS) |
| `--dry-run`, `--no-path`, `--verbose`, `--keep-zip`, `--zip-path`, `--skip-non-versioned-files`, `--jsonfile` (global.json) | misc |

## Install location
- Order: `--install-dir` -> `$DOTNET_INSTALL_DIR` -> `$HOME/.dotnet`.
- Exits if version already present. Non-versioned files (e.g. `dotnet` binary) overwritten unless `--skip-non-versioned-files`.
- Does not install system dependencies.
