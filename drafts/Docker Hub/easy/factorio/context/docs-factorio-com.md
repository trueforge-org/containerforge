# factorio.com (vendor site, downloads and release API)

**Source URL(s) + fetch date**
- https://factorio.com/ (homepage)
- https://factorio.com/api/latest-releases
- https://factorio.com/download/sha256sums/
- Draft binary link pattern: https://factorio.com/get-download/stable/headless/linux64
- Fetched 2026-11-26

**What it is**
Vendor site for Factorio, a commercial game by Wube Software. Sold via Steam, GOG and the official shop. A demo and a Nintendo Switch version are mentioned. Homepage footer: all rights reserved by Wube Software, Terms of Service and Privacy links. No headless server licence terms on the homepage.

**Version info (API)**
`https://factorio.com/api/latest-releases` returned:
`{"experimental":{"alpha":"2.1.25","demo":"2.1.23","expansion":"2.1.25","headless":"2.1.25"},"stable":{"alpha":"2.1.25","demo":"2.1.23","expansion":"2.1.25","headless":"2.1.25"}}`
Stable headless = `2.1.25`. Homepage also lists stable and experimental as 2.1.25.

**Download URL pattern**
- `https://factorio.com/get-download/<version>/headless/linux64` (x64) and `.../headless/linux-arm64` (arm64, 2.1+).
- Draft's `get-download/stable/headless/linux64` is a vendor alias; the version form is the one the Dockerfile uses.
- Redirects to `dl.factorio.com` (not fetched here).

**Checksums (sha256sums page)**
Plain text `<sha256>  <file>`. For 2.1.25:
- `78da2f5aa99e9e0af7586d6bf82c04aae91165d53036720dabb26e855688f3ae  factorio-headless_linux_2.1.25.tar.xz`
- `c10ab4008043713b6e37097850c69ff675acac7ab965e87d768ce46d0c1753fd  factorio-headless_linux-arm64_2.1.25.tar.xz`
- Headless linux64 tarballs listed from 2.0.43 upward; linux-arm64 headless listed for 2.1.18 to 2.1.25 only. Page is long; list was truncated in fetch.

**Arch support**
x64 and arm64 (2.1.18 onward for arm64 headless, per sha256sums list).

**Gotchas**
- Stable headless version is 2.1.25 per API. plan.md section 1 agrees.
- The sha256sums list is on the same origin as the download, so it protects against corruption only.

**Contradictions with plan.md**
- plan.md section 1 says the draft's arm64 "not available" is outdated for 2.1+. Confirmed: arm64 headless 2.1.25 is listed with a checksum.
- plan.md says the Factorio ToS prohibits redistribution. Not checked here (ToS page not fetched). Unverified.
