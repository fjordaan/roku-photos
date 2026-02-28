"""
indexer.py — Scans LIBRARY_ROOT and builds/updates a SQLite photo index.

Usage: python3 indexer.py

Run once to build the initial DB (~few minutes for 110K photos),
then re-run after adding/removing photos to keep it current.
"""

import os
import sqlite3
import time
from config import LIBRARY_ROOT, DB_PATH, SUPPORTED_EXTENSIONS


def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db(conn):
    conn.execute("""
        CREATE TABLE IF NOT EXISTS photos (
            id       INTEGER PRIMARY KEY,
            path     TEXT UNIQUE NOT NULL,
            filename TEXT NOT NULL,
            mtime    REAL NOT NULL
        )
    """)
    conn.execute("CREATE INDEX IF NOT EXISTS idx_photos_path ON photos (path)")
    conn.commit()


def index_library():
    conn = get_db()
    init_db(conn)

    print(f"Scanning {LIBRARY_ROOT} ...")
    start = time.time()

    # Collect all current paths on disk
    disk_paths = set()
    scanned = 0
    upserted = 0

    for dirpath, dirs, filenames in os.walk(LIBRARY_ROOT):
        # Skip Synology metadata dirs (@eaDir, @sharebin, etc.)
        dirs[:] = [d for d in dirs if not d.startswith("@")]
        for filename in filenames:
            ext = os.path.splitext(filename)[1].lower()
            if ext not in SUPPORTED_EXTENSIONS:
                continue

            abs_path = os.path.join(dirpath, filename)
            rel_path = os.path.relpath(abs_path, LIBRARY_ROOT).replace(os.sep, "/")
            mtime = os.path.getmtime(abs_path)

            disk_paths.add(rel_path)

            conn.execute(
                """
                INSERT INTO photos (path, filename, mtime)
                VALUES (?, ?, ?)
                ON CONFLICT(path) DO UPDATE SET
                    filename = excluded.filename,
                    mtime    = excluded.mtime
                WHERE excluded.mtime != photos.mtime
                """,
                (rel_path, filename, mtime),
            )
            upserted += 1
            scanned += 1

            if scanned % 1000 == 0:
                conn.commit()
                elapsed = time.time() - start
                print(f"  {scanned} files scanned ({elapsed:.0f}s)...")

    conn.commit()

    # Remove DB rows for files no longer on disk
    cursor = conn.execute("SELECT path FROM photos")
    db_paths = {row["path"] for row in cursor}
    stale = db_paths - disk_paths
    if stale:
        conn.executemany("DELETE FROM photos WHERE path = ?", [(p,) for p in stale])
        conn.commit()
        print(f"Removed {len(stale)} stale entries from DB.")

    elapsed = time.time() - start
    total = conn.execute("SELECT COUNT(*) FROM photos").fetchone()[0]
    conn.close()

    print(f"Done. {scanned} files scanned, {total} total in DB ({elapsed:.1f}s).")


if __name__ == "__main__":
    index_library()
