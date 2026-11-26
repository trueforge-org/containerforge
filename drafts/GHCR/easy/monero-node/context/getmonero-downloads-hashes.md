# getmonero.org: canonical SHA-256 hash list (v0.18.5.4)

**Source URL(s):** https://getmonero.org/downloads/hashes.txt
**Fetched:** 2026-11-26
(Not `https://downloads.getmonero.org/cli/hashes.txt`: plan.md recorded that as HTTP 404.)

## Content
- Clearsigned PGP message: `-----BEGIN PGP SIGNED MESSAGE-----`, `Hash: SHA256`, then the signature block (signer tag `# ~binaryFate`). The signature block was not verified in this session.
- Lines for this release (exact):
  - `d20d71e6522b41eb8e549c3425f7f4622c9c9a448fc7147525393fd0a6b59703  monero-linux-armv8-v0.18.5.4.tar.bz2`
  - `ba2928962c101b609434bf8c1b43ad59ebe96c5525977284ca599d8bf0f02d10  monero-linux-x64-v0.18.5.4.tar.bz2`
- Date: not stated in the file.

## Relevance to the plan
- These two values match the locally computed SHA-256 values recorded in plan.md section 1 (amd64 `ba2928962c101b609434bf8c1b43ad59ebe96c5525977284ca599d8bf0f02d10`, armv8 `d20d71e6522b41eb8e549c3425f7f4622c9c9a448fc7147525393fd0a6b59703`).
- So the Dockerfile `ARG MONERO_SHA256_*` values can be taken from this canonical list. The PGP signature is still unverified (the release notes say to check it against `utils/gpg_keys` in the source tree).
