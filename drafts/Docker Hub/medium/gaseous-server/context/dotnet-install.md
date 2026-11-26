# dot.net/v1/dotnet-install.sh (builds.dotnet.microsoft.com copy)

Source URL(s): https://dot.net/v1/dotnet-install.sh (301 -> https://builds.dotnet.microsoft.com/dotnet/scripts/v1/dotnet-install.sh, followed)
Date: fetched 2026-11-26

- Official .NET Foundation script (MIT). Installs SDK or shared runtime from Microsoft feeds without admin rights (CI-oriented). Needs curl (preferred) or wget. Does not install OS deps.
- Flags: `-c/--channel` (default LTS; STS, A.B, A.B.Cxx; Current -> STS); `-v/--version` (default latest; overrides channel); `-q/--quality` (daily|preview|ga, ignored for LTS/STS); `-i/--install-dir`; `--runtime` (dotnet|aspnetcore; omit for SDK); `--arch` (x64, arm, arm64, s390x, ppc64le, loongarch64; auto); `--os` (osx|macos, linux, linux-musl, freebsd, rhel.6); `--dry-run`, `--no-path`, `--verbose`, `--jsonfile` (global.json), `--keep-zip`, `--zip-path`, `--skip-non-versioned-files`.
- Install dir order: `--install-dir` -> `$DOTNET_INSTALL_DIR` -> `$HOME/.dotnet`.
- Skips if version present; retries downloads; `set -e -u`, pipefail.
