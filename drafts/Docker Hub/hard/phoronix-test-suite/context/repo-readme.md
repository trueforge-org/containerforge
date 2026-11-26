# phoronix-test-suite README (master)

Source URL: https://raw.githubusercontent.com/phoronix-test-suite/phoronix-test-suite/master/README.md (fetched; repo root)

- What: open-source benchmarking/testing platform (Linux best supported; also macOS, Windows, BSD, Solaris). Automates install, run, reporting. 600+ profiles, 200+ suites via OpenBenchmarking.org.
- License: GNU GPLv3. Developed by Phoronix Media.
- Runtime dep: command-line PHP only (5.3+; PHP 7 and 8 supported). Package names: php, php-cli. Extensions: DOM required (php-xml); ZIP, OpenSSL, PCNTL, POSIX for features; GD, Zlib recommended; CURL, FPDF optional. php.ini needs allow_url_fopen, file_uploads, allow_url_include true for uploads/login.
- Install: system-wide install, or run locally from extracted archive.
- Docker not mentioned in README.
- Basic usage: phoronix-test-suite benchmark|install|run|batch-setup|batch-run|system-info
- Docs: documentation/phoronix-test-suite.md in repo.
