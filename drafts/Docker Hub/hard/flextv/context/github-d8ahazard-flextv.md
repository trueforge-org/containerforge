# GitHub: d8ahazard/FlexTV

Source URL(s) + fetch date (2026-11-26):
- https://github.com/d8ahazard/FlexTV (repo root tree)
- https://raw.githubusercontent.com/d8ahazard/FlexTV/master/readme.md (README; lowercase name, `README.md` 404s)
- https://api.github.com/repos/d8ahazard/FlexTV/releases/latest (404: no latest release)
- https://github.com/d8ahazard/FlexTV/releases (page: "There aren't any releases here")

## What it is

- Connects Plex to voice assistants (Google Home etc.). README: "beta development" branch, code and features may change.
- Self-hostable per README, but the README gives no install commands. Wiki is self-described as outdated.
- Hosted web-only version at https://app.phlexchat.com runs the same code (not fetched; plan mention only).
- Plex Media Server is implied (Chromecast plugin runs inside it, separate repo https://github.com/d8ahazard/FlexTV.bundle, not fetched).

## Language / repo layout

- Default branch: `master`. Total 795 commits (commit date not shown).
- Root folders: `.idea`, `css`, `img`, `js`, `log`, `logs`, `php`, `rw`.
- Root files: `api.php`, `index.php`, `log.php`, `PHPTail.php`, `composer.phar`, `cacert.pem`, `manifest_template.json`, `service-worker.js`, `_config.yml`, `browserconfig.xml`, `favicon.ico`, `gpl.txt`, `license.txt`, `readme.md`, `ISSUE_TEMPLATE.md`, `.gitignore`, `.gitattributes`.
- Confirms PHP (plan section 1 is correct: PHP, not Python). README itself does not name the language.
- `log`, `logs`, `rw` are the write-target folders (plan's assumption; write behaviour not verified).

## Install/build steps and deps

- None in README. No composer.json seen in the root listing (plan's `composer install` step is UNVERIFIED).

## Env vars / ports / config

- None documented in README or releases. Port unknown from source.

## Version / release info

- No GitHub releases; latest-release API returns 404. Pin by commit SHA (plan's approach stands).
- Tags link exists on repo page but no tag names were visible.

## License

- README does not state a license. Root contains `license.txt` and `gpl.txt`. License name NOT confirmed from fetched content (plan: "suggests GPL", still UNVERIFIED).

## Gotchas

- Branch is "beta development" (README). Wiki admits it is outdated.
- Plan's claim "README states no license" is consistent with the fetched readme.
- Wiki Docker page documents a different image than the draft's (see `github-d8ahazard-flextv-wiki.md` and `dockerhub-jcreynolds-flextv.md`).
