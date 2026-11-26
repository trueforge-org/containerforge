# chvb/docker-kerio-connect README

Source URL(s): https://raw.githubusercontent.com/chvb/docker-kerio-connect/eb6b9083dd9e9a68e4a67b73c178a0450cecd8ca/README.md. Fetched 2026-11-26.

## What
- Unofficial, private Kerio Connect (Linux mail/groupware) Docker build. States "NO CONNECTION TO KERIO COMPANY", use at own risk.

## Install
- `docker pull chvb/docker-kerio-connect:latest`
- Build: `git clone https://github.com/chvb/docker-kerio-connect.git && cd docker-kerio-connect && sudo docker build -t docker-kerio-connect .`

## Ports
- 4040 admin HTTPS; 22 SSH; 25/465/587 SMTP; 110/995 POP3; 143/993 IMAP; 119/563 NNTP; 389/636 LDAP; 80/443 HTTP(S); 5222/5223 XMPP

## Volumes
- host config -> `/opt/kerio`; host data -> `/kerio_store`; host backup -> `/backup`

## Env
- None documented.

## Admin / restore / update
- Admin: `https://IP:4040`; stop: `sudo service kerio-connect stop`
- Restore: SSH in, stop service, `sudo /opt/kerio/mailserver/kmsrecover /backup`, start service
- Update: pull and rerun; keep `*.cfg` and `mailserver/{store,dbSSL,license,settings,sslca,sslcert,ldapmap}`
- Version: README states none; Docker Hub shows 9.2.9 Patch 1 in description (see hub file)
