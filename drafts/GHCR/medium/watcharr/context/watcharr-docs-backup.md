# Watcharr docs: Backing up

Source URL(s): https://watcharr.app/docs/server_config/backup (fetched 2026-11-27)

- Watcharr has no built-in backup; back up its data directory with normal tooling.
- Shut down the server before backing up (corruption risk, mainly the database).
- Data dir `./data` holds `watcharr.db` and `watcharr.db-wal` (SQLite with WAL).
- Test a restore from the first backup.
