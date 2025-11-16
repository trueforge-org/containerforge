import os
import sqlite3

DB_FILE = os.environ.get("DB_FILE", "/config/api.db")
# Increment to drop tables and start over
DB_SCHEMA_VERSION = 1


def set_db_schema():
    conn = sqlite3.connect(DB_FILE)
    conn.execute("CREATE TABLE IF NOT EXISTS db_schema (key TEXT UNIQUE, version INTEGER DEFAULT 0)")
    is_updated = conn.execute(f"SELECT 1 FROM db_schema WHERE version = {DB_SCHEMA_VERSION}").fetchone() is not None
    if not is_updated:
        conn.execute(f"DROP TABLE IF EXISTS kv")
        conn.execute(f"REPLACE INTO db_schema (key, version) VALUES('schema_version', {DB_SCHEMA_VERSION})")
        conn.commit()
    conn.close()

class KeyValueStore(dict):
    def __init__( self, invalidate_hours=24, readonly=True):
        self.invalidate_hours = invalidate_hours
        self.readonly = readonly
        if not readonly:
            self.conn = sqlite3.connect(DB_FILE)
            self.conn.execute("CREATE TABLE IF NOT EXISTS kv (key TEXT UNIQUE, value TEXT, updated_at TEXT, schema_version INTEGER)")
            self.conn.commit()
            self.conn.close()
    def __enter__(self):
        self.conn = sqlite3.connect(DB_FILE, uri=self.readonly)
        return self
    def __exit__(self, exc_type, exc_val, exc_tb):
        if not self.readonly:
            self.conn.commit()
        self.conn.close()
    def __contains__(self, key):
        where_clause = "" if self.invalidate_hours == 0 else f" AND updated_at >= DATETIME('now', '-{self.invalidate_hours} hours', 'utc')"
        return self.conn.execute(f"SELECT 1 FROM kv WHERE key = '{key}' {where_clause}").fetchone() is not None
    def __getitem__(self, key):
        item = self.conn.execute("SELECT value FROM kv WHERE key = ?", (key,)).fetchone()
        return item[0] if item else None
    def set_value(self, key, value, schema_version):
        self.conn.execute("REPLACE INTO kv (key, value, updated_at, schema_version) VALUES (?, ?, DATETIME('now', 'utc'), ?)", (key, value, schema_version))
        self.conn.commit()
    def is_current_schema(self, key, schema_version):
        return self.conn.execute(f"SELECT 1 FROM kv WHERE key = '{key}' AND schema_version = {schema_version}").fetchone() is not None
