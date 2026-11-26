# documentation/phoronix-test-suite.md (repo, follow-up)

Source URL: https://raw.githubusercontent.com/phoronix-test-suite/phoronix-test-suite/master/documentation/phoronix-test-suite.md (fetched; text truncated at ~100k chars before PTS_* env list complete)

## Path defaults (non-root)
| Item | Default |
| --- | --- |
| Base dir | ~/.phoronix-test-suite/ |
| Config | ~/.phoronix-test-suite/user-config.xml (root: /etc/phoronix-test-suite.xml) |
| Download cache | ~/.phoronix-test-suite/download-cache/ |
| Installed tests | ~/.phoronix-test-suite/installed-tests/ |
| Results | ~/.phoronix-test-suite/test-results/ |
| Test profiles / suites | ~/.phoronix-test-suite/test-profiles/ , test-suites/ |
| Modules data / Phoromatic | ~/.phoronix-test-suite/modules-data/ , phoromatic/ |
| System-wide install | /usr/bin/ executable; /usr/share/phoronix-test-suite/; /usr/share/doc/phoronix-test-suite/ |

## PTS_* env vars (in visible text)
| Var | Purpose |
| --- | --- |
| PTS_CONCURRENT_TEST_RUNS | concurrent runs in stress-run; default 2 |
| PTS_FLUSH_CACHES | Flush Caches module |
| PTS_MODULES | load modules from env |
| PTS_USER_PATH | launcher-file variable: absolute path to root holding pts and pts-core |
- PTS_USER_PATH_OVERRIDE, PTS_DOWNLOAD_CACHE_OVERRIDE, PTS_DOWNLOAD_CACHING_PLATFORM_LIMIT, TESTS_TO_PRECACHE: not documented in fetched text.

## Other env (visible)
FORCE_TIMES_TO_RUN, FORCE_MIN_TIMES_TO_RUN, MONITOR, NO_DOWNLOAD_CACHE, NO_EXTERNAL_DEPENDENCIES, OUTPUT_DIR / OUTPUT_FILE.

## Requirements
- PHP 5.3+ CLI; DOM required; ZIP, OpenSSL, PCNTL, POSIX for features; GD/Zlib recommended.
