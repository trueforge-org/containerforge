# Upstream: thibaud-rohmer/PhotoShow master HEAD

Source URL (fetched 2026-11-27):
- https://api.github.com/repos/thibaud-rohmer/PhotoShow/commits/master

- Commit `3c3819f6555c1c7819ee31f6c090da44d0ce2428`
- Date 2025-01-13T09:16:26Z, author Thibaud Rohmer.
- Message: "Merge pull request #375 from cyosp/feature/reduce_docker_image".

## Gotchas
- linuxserver's `version-48aabb98` label builds a different commit (not 3c3819f). The commit behind the label is not verified here.
- The linuxserver image clones master at start (via `/version.txt` SHA), so runtime content depends on the commit pinned at build.
