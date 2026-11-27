# Apt-Cacher NG project site and user manual

**Source URL(s):** https://www.unix-ag.uni-kl.de/~bloch/acng ; /~bloch/acng/html (manual index); /~bloch/acng/html/usage.html (fetched 2026-11-27; main index + usage.html follow-up)

## What it is
- Apt-Cacher NG: caching proxy for package files from Linux distributors (primarily Debian and derivatives). Uses native system functions, no interpreter, does not fork during operation.
- Has a web frontend for statistics reports and actions (e.g. import package files).
- Obtain: download current version from Debian mirror of choice (package `apt-cacher-ng`).

## Client usage
- Clients modify mirror URLs or set APT HTTP proxy to the server.

## Running (manual chapter 2)
- `apt-cacher-ng -c <conf-dir>` where conf is the configuration directory (see config file types, section 4.2).
- Options may be passed as command-line args in config-file format, e.g. `Port:4855 ForeGround=1`; `:` and `=` both accepted; case-insensitive.

## Manual chapter list (for reference)
- 3.1 Server config, 3.2 Client config, 4.2 config file types, 4.3 repository/URL mapping, 5 Security (ACL, libwrap, iptables, target port filter), 6 distribution-specific hints (Debian/Ubuntu, etc.), 7 maintenance (cache cleanup), 8 HOWTOs (package import, SSL/TLS remotes).

## Gotchas
- Manual page for Ch. 3 config and ports was not fetched (not in budget); port 3142 and `ForeGround`/`PassThroughPattern` keys come from upstream Dockerfile, not the manual.
