# ring-mqtt release v5.9.3 (GitHub API)

Source: https://github.com/tsightler/ring-mqtt/releases/tag/v5.9.3 ; API https://api.github.com/repos/tsightler/ring-mqtt/releases/tags/v5.9.3 , fetched 2026-11-26

| Field | Value |
| --- | --- |
| tag_name | v5.9.3 |
| name | Release v5.9.3 |
| target_commitish | main |
| published_at | 2026-03-09T03:54:47Z |
| prerelease / draft | false / false |
| assets | none (source tarball/zipball only) |
| tarball | https://api.github.com/repos/tsightler/ring-mqtt/tarball/v5.9.3 |

## Body (summary)
- Updated ring-client-api with patched push-receiver to fix push-message decryption failures (ERR_CRYPTO_ECDH_INVALID_PUBLIC_KEY), which could miss motion/ding events.
- Fixed crash with Sidewalk-only Ring device (smoke/CO detector) when no security panel.
- Fixed Kiddie smoke/CO state updates.

## Gotchas
- Tag has `v` prefix; chart/plan tag is `5.9.3` without prefix.
