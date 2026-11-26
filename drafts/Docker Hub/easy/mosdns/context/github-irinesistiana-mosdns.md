# IrineSistiana/mosdns (upstream application)

**Source URL(s) + fetch date:** https://github.com/IrineSistiana/mosdns ; https://raw.githubusercontent.com/IrineSistiana/mosdns/main/README.md (returned almost no content, see gotchas) ; https://github.com/IrineSistiana/mosdns/releases/latest ; https://api.github.com/repos/IrineSistiana/mosdns/releases/tags/v5.3.4 · fetched 2026-11-26

## What it is
Go DNS forwarder / splitter built around plugins. Ships as a single binary. Project licence is GPL-3.0 (per wiki; plan.md says SPDX GPL-3.0-or-later with LICENSE = GPL v3).

## Install/build steps and build deps
- Upstream publishes prebuilt zip archives per platform on GitHub Releases. No build needed for the ContainerForge plan.
- Upstream builds from source with Go (release notes for v5.3.4: "Dependencies updated, with Go 1.25").

## Runtime deps
None beyond the binary (no runtime language). Certificates needed only for DoT/DoH upstreams.

## Binaries/entrypoint/CLI flags
- Binary: `mosdns` (single file).
- Start: `mosdns start -c <config file> -d <working dir>` (`-c` config file, `-d` working directory).
- Other subcommands: `probe` (TCP/TLS connection-reuse check), `config` (generate YAML template / convert formats), `service install|start|stop|uninstall` (system service, needs root).
- Help: `mosdns -h`, `mosdns probe -h`.

## Env vars
None documented by upstream (wiki page lists none).

| Variable | Default | Purpose |
| --- | --- | --- |
| (none) | - | upstream reads no environment variables per wiki |

## Ports
Configured in the YAML config, not by a default. Wiki examples use `listen: 127.0.0.1:5533` for `udp_server` and `tcp_server` (same port for both). Wiki examples bind 127.0.0.1, which is not reachable from other containers; the listen address must be changed to `0.0.0.0:<port>` for container use. Api/http server is off unless `api.http` is set (example `127.0.0.1:8080`).

## Volumes/paths and persistent data
- Config format is read from the path passed to `-c`; `-d` sets the working directory (relative paths resolve from there).
- Nothing is required to be persisted by upstream itself. Rule/list files and optional log file (`log.file`) are user-chosen paths.

## User/UID & permissions
Not specified upstream.

## Config files and formats
- YAML by default; JSON and TOML also accepted (format detected from file extension).
- Top-level keys: `log` (`level`: debug|info|warn|error, default info; `production`: JSON-only output; `file`: experimental log file, stderr by default), `api` (experimental; `http`: listen address), `include` (list of other config files whose plugins load first), `plugins` (list).
- Plugin entry: `tag` (optional unique name), `type`, `args` (type-specific).
- Plugins initialise in file order; a `sequence` can only call plugins declared before it.
- Server plugin types: `udp_server`, `tcp_server` (args `entry`, `listen`). Other server types on the wiki index: DoT, DoH (incl. H3), DoQ.
- Example minimal forwarder:
  ```yaml
  plugins:
    - tag: forward_google
      type: forward
      args:
        upstreams:
          - addr: https://8.8.8.8/dns-query
  ```
  A server's `entry` may point directly at a `forward` plugin.

## Healthcheck/readiness endpoints
None upstream. DNS query check is the practical readiness test (e.g. `dig @127.0.0.1 -p <port>`). Probe subcommand exists but targets remote TCP/TLS servers.

## Version/release info and asset naming
- Latest release: **v5.3.4** (tag `v5.3.4`, published 2026-01-11T11:42:56Z, marked Latest). Release notes: Go 1.25 build; forward: UDP upstream with no answer after 1 s is resent; concurrent mode avoids reusing the same upstream.
- Tag format has `v` prefix (`v5.3.4`).
- Asset naming (exact, from the API): `mosdns-<os>-<arch>.zip`. Linux assets: `mosdns-linux-amd64.zip`, `mosdns-linux-arm64.zip`, `mosdns-linux-arm-5.zip`, `mosdns-linux-arm-6.zip`, `mosdns-linux-arm-7.zip`, `mosdns-linux-mips64le-hardfloat.zip`, `mosdns-linux-mipsle-softfloat.zip`, `mosdns-linux-ppc64le.zip`. Other: darwin, freebsd, windows zips. Each zip contains the `mosdns` binary.
- Download URL pattern: `https://github.com/IrineSistiana/mosdns/releases/download/v<version>/mosdns-linux-<arch>.zip`.
- No checksum asset was listed in the API response.

## Arch support
Linux amd64, arm64, arm v5/v6/v7, mips64le, mipsle, ppc64le (release assets). Plan uses amd64 + arm64 only.

## Gotchas
- Wiki example configs bind `127.0.0.1`, which breaks cross-container access. Listen on `0.0.0.0`.
- Plugin initialisation order matters (`sequence` may only reference earlier plugins).
- Experimental features (`log.file`, `api`) carry no compatibility guarantee.
- GitHub release page asset list did not render in the fetch; asset names above come from the API instead.
- Agreement with plan.md: release tag v5.3.4, zip per arch, GPL-3.0, `-c`/`-d` start flags, and 127.0.0.1 example binding are all consistent with the plan.
