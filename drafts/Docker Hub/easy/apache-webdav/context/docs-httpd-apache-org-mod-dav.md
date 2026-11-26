# Apache httpd 2.4: mod_dav

**Source URL(s) + fetch date**
- https://httpd.apache.org/docs/2.4/mod/mod_dav.html (fetched 2026-11-26)

**Facts**
- Module `dav_module` (source `mod_dav.c`), class 1 and 2 WebDAV. Status: Extension.
- Directives in mod_dav: `Dav On|Off|provider-name` (default Off, directory context); `DavBasePath` (2.4.58+); `DavDepthInfinity on|off` (default off; DoS risk); `DavMinTimeout seconds` (default 0; Microsoft Web Folders default 120).
- `DavLockDB` is NOT a mod_dav directive. It belongs to `mod_dav_fs` and must be in the global section. Example `DavLockDB /usr/local/apache2/var/DavLock`. The directory holding the lock DB must be writable by the httpd `User`/`Group`.
- `Dav On` is an alias for the `filesystem` provider (`mod_dav_fs`). Once DAV is enabled for a location, it cannot be disabled for sublocations.
- `mod_dav_fs` must be compiled in or loaded with `LoadModule`. The page does not mention `mod_dav_lock`.
- `LimitXMLRequestBody` limits DAV request size; `LimitRequestBody` has no effect on DAV.
- Security notes: protect DAV locations with auth; Basic is not recommended without TLS (use Digest or Basic over SSL); Apache owns the written files.
- Dynamic content: a GET runs scripts; a `ForceType text/plain` workaround is documented.
