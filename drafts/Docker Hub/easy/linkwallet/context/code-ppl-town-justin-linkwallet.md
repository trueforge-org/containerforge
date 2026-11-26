# justin/linkwallet (code.ppl.town, Forgejo)

Source URL(s) + fetch date:
- https://code.ppl.town/justin/linkwallet (repo; plan's "moved" target)
- https://code.ppl.town/justin/linkwallet/releases
- Fetched 2026-11-26

## Status
- Upstream canonical home per GitHub README (see github-tardisx-linkwallet.md). The repo page did not itself state a move.
- Default branch `main`. 2 branches. Most recent commit "Add test", 2025-05-04.
- MIT license (linked LICENSE file).
- Self-described: self-hosted bookmark database with full-text page content search (Bleve).

## Releases
- 36 releases, 41 tags. Page 1 (newest first): v0.1.1 (2025-05-04, marked latest by position; no explicit badge; every release shows a "Stable" label, 0 commits to main since), v0.1.0 (2025-05-03), v0.0.35 and v0.0.36 (2022-12-17, same commit hash), v0.0.34 to v0.0.31 (2022-08-21), v0.0.30 and v0.0.29 (2022-08-20).
- v0.1.1 notes: show the URL in search results when the title is empty (commit `b50a2ae`).
- v0.1.0 notes: adds Bleve indexing, which triggers an automatic full re-scrape.
- Assets: checksums file per release (`linkwallet_0.1.1_checksums.txt`, 873 B; v0.0.29 to v0.0.36 have `checksums.txt`, 1.4 KiB). No sha256 values shown on the page.
- v0.1.x assets: tar.gz for Darwin (arm64, x86_64), Freebsd (arm64, x86_64), Linux (arm64, armv6, armv7, x86_64), Windows x86_64 zip.
- v0.0.29 to v0.0.36: .deb (amd64, arm64, i386), .rpm (aarch64, i386, x86_64), tar.gz for Darwin, Linux, Windows.
- Source code as ZIP and TAR.GZ on each release.

## Relevance to plan.md
- Plan section 1 says the Forgejo releases page lists v0.1.1 as latest. Consistent (by position and date).
- Plan's checksum values (`cc0710ac...` amd64, `ce4aa3c0...` arm64) are not visible on this page; the checksums files were not fetched.
