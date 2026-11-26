# leenooks/phpLDAPadmin README (master)

Source URL: https://raw.githubusercontent.com/leenooks/phpLDAPadmin/master/README.md (fetched)

- What: web LDAP admin tool ("PLA"); v2 is a full rewrite; v1.2x and earlier deprecated/unsupported. Works with any RFC-compliant LDAP.
- License: LICENSE file linked; name not stated.
- PHP: not specified; "runs wherever PHP runs". v1 targeted PHP 5.
- Install: Docker is easiest; official image phpldapadmin/phpldapadmin (x86_64, arm64; s390x planned); or release download on PHP server.
- Config location: not stated (wiki Installation Instructions). Custom templates under templates/custom.
- Supported LDAP: 389 DS, Apache DS, OpenBSD ldapd, OpenLDAP, OpenDJ, Samba AD.
- v1 -> v2 upgrade: manual; templates change XML -> JSON.
- Wiki: /wiki/Docker-Container, /wiki/Installation-Instructions.
