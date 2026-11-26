# dotnet-install.sh (Microsoft .NET install script, used by plan.md)

Source URL(s) + fetch date:
- https://dot.net/v1/dotnet-install.sh · fetched 2026-11-26 (301 to builds.dotnet.microsoft.com)
- https://builds.dotnet.microsoft.com/dotnet/scripts/v1/dotnet-install.sh · fetched 2026-11-26

## Options
- `-c`/`--channel`: default **LTS**; accepts STS, LTS, `A.B`, or `A.B.Cxx`. `Current` is deprecated (maps to STS).
- `-v`/`--version`: default `Latest`; a specific three-part version overrides the channel.
- `--runtime`: `dotnet` (Microsoft.NETCore.App) or **`aspnetcore`** (Microsoft.AspNetCore.App); `windowsdesktop` rejected. Installs a runtime without the SDK.
- `-i`/`--install-dir`; env `DOTNET_INSTALL_DIR`; default `$HOME/.dotnet`.
- `--architecture`/`--arch`: default auto-detected; x64, arm, arm64, s390x, ppc64le, loongarch64; `amd64` alias accepted.
- `--os`: osx (macos), linux, linux-musl, freebsd, rhel.6.

## Integrity
**No checksum verification.** Only a Content-Length comparison (mismatch prints a warning, install continues), and a check that the version folder exists after extraction.

## Relevance
Plan.md step 4 uses `-c 9.0 --install-dir /app/dotnet --runtime aspnetcore`. The script supports this (`-c 9.0` is a two-part channel). Plan's note to pin the version or mirror the script with a checksum still applies.
