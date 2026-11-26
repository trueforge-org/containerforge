# emweb/wt (Wt, C++ Web Toolkit)

Source URL(s) + fetch date:
- https://github.com/emweb/wt (fetched 2026-11-26)
- Tarball (not downloaded, binary archive): https://github.com/emweb/wt/archive/${WT_VERSION}.tar.gz

## What it is

C++ web application library: widget/rendering (libwt), async HTTP/WebSocket server (libwthttp), FastCGI and ISAPI connectors, test connector. Includes C++ ORM (Dbo) with backends PostgreSQL, Sqlite3, MySQL/MariaDB, MSSQL, Firebird.

## Build requirements

- Required: CMake, Boost, C++ compiler (GCC, Clang, MSVC). Versions in `doc/MinimumDependencyVersions.md` (not fetched).
- Optional: OpenSSL (SSL/WebSockets in built-in httpd, HTTP client, hashes), zlib (compression), SQLite (Sqlite3 Dbo backend; build flag not named on the page), Haru PDF, GraphicsMagick, PostgreSQL, MySQL, ODBC + unixODBC, Firebird, Pango, libfcgi++ (FastCGI).
- Explicit CMake option names are not listed on the page; build instructions are in the Unix/Windows install guides.
- Upstream fileshelter Dockerfile uses: `-DSHARED_LIBS=ON -DCMAKE_CXX_STANDARD=20 -DBUILD_EXAMPLES=OFF -DENABLE_LIBWTTEST=OFF -DCONNECTOR_FCGI=OFF -DWT_CPP17_FILESYSTEM_IMPLEMENTATION=std -DWT_CPP17_ANY_IMPLEMENTATION=std -DWT_CPP20_DATE_TZ_IMPLEMENTATIO=std`.

## License

- Dual-licensed: GNU GPL version 2 only, with OpenSSL exception; or a commercial license. Full list of bundled licenses at `doc/licenses.md`.

## Version/release info

- Repo page shows no releases (releases section empty in the capture). Upstream fileshelter pins `4.12.3`. Plan says latest is 4.15.0 (not verified here).

## Gotchas

- The page does not state the GPL-2.0 "only" vs "or later" wording beyond "GPL version 2 only, with OpenSSL exception" (stated).
