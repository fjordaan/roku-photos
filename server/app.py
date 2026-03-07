import os
import random
import sqlite3
import hashlib
import subprocess
import tempfile
import datetime
from urllib.parse import quote
from flask import Flask, jsonify, send_file, abort, request
from config import LIBRARY_ROOT, SERVER_PORT, NAS_IP, SUPPORTED_EXTENSIONS, DB_PATH, DEFAULT_PLAYLIST_LIMIT, RESIZE_WIDTH, CACHE_DIR

app = Flask(__name__)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def iter_photos():
    """Recursively yield supported photo files under LIBRARY_ROOT in random order."""
    for dirpath, dirs, filenames in os.walk(LIBRARY_ROOT):
        # Skip Synology metadata dirs (@eaDir, @sharebin, etc.)
        dirs[:] = [d for d in dirs if not d.startswith("@")]
        random.shuffle(dirs)
        random.shuffle(filenames)
        for filename in filenames:
            if os.path.splitext(filename)[1].lower() in SUPPORTED_EXTENSIONS:
                yield os.path.join(dirpath, filename)


def photo_url(rel_path):
    return f"http://{NAS_IP}:{SERVER_PORT}/photos/{quote(rel_path)}?w={RESIZE_WIDTH}"


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@app.route("/api/status")
def status():
    return jsonify({"status": "ok"})


@app.route("/api/playlist")
def playlist():
    order       = request.args.get("order", "random")
    limit       = request.args.get("limit", DEFAULT_PLAYLIST_LIMIT, type=int)
    filter_type = request.args.get("type", "all")   # "all" or "folder"
    filter_path = request.args.get("path", "")      # folder path for type=folder

    # Use SQLite index when available; fall back to filesystem walk on first deploy.
    if os.path.isfile(DB_PATH):
        photos = _playlist_from_db(order, limit, filter_type, filter_path)
    else:
        photos = _playlist_from_fs(limit)

    return jsonify(photos)


def _playlist_from_db(order, limit, filter_type="all", filter_path=""):
    order_clause = "ORDER BY RANDOM()" if order != "az" else "ORDER BY filename"

    where_clause = ""
    params = []

    if filter_type == "folder" and filter_path:
        # Normalise: strip trailing slash, then match direct children only
        folder = filter_path.rstrip("/")
        where_clause = "WHERE path LIKE ? AND path NOT LIKE ?"
        params.append(folder + "/%")
        params.append(folder + "/%/%")  # exclude sub-folders

    params.append(limit)

    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    try:
        rows = conn.execute(
            f"SELECT path, filename, mtime FROM photos {where_clause} {order_clause} LIMIT ?",
            params,
        ).fetchall()
    finally:
        conn.close()

    return [
        {
            "url":      photo_url(row["path"]),
            "path":     row["path"],
            "filename": row["filename"],
            "date":     datetime.datetime.fromtimestamp(row["mtime"]).strftime("%d %B %Y %H:%M:%S"),
        }
        for row in rows
    ]


def _playlist_from_fs(limit):
    photos = []
    for abs_path in iter_photos():
        rel_path = os.path.relpath(abs_path, LIBRARY_ROOT).replace(os.sep, "/")
        photos.append({
            "url":      photo_url(rel_path),
            "path":     rel_path,
            "filename": os.path.basename(abs_path),
            "date":     datetime.datetime.fromtimestamp(os.path.getmtime(abs_path)).strftime("%d %B %Y %H:%M:%S"),
        })
        if len(photos) >= limit:
            break
    return photos


@app.route("/photos/<path:photo_path>")
def serve_photo(photo_path):
    abs_path = os.path.realpath(os.path.join(LIBRARY_ROOT, photo_path))
    library_root = os.path.realpath(LIBRARY_ROOT)
    if not abs_path.startswith(library_root + os.sep):
        abort(403)
    if not os.path.isfile(abs_path):
        abort(404)
    width = request.args.get("w", type=int)
    if width:
        return serve_resized(abs_path, width)
    return send_file(abs_path)


def serve_resized(abs_path, width):
    cache_key = hashlib.md5(f"{abs_path}:{width}".encode()).hexdigest()
    cache_path = os.path.join(CACHE_DIR, cache_key + ".jpg")

    if not os.path.isfile(cache_path):
        os.makedirs(CACHE_DIR, exist_ok=True)
        # Write to a temp file then rename atomically so concurrent requests
        # never read a partially-written cache file.
        fd, tmp_path = tempfile.mkstemp(dir=CACHE_DIR, suffix=".tmp")
        os.close(fd)
        try:
            subprocess.run(
                [
                    "convert",
                    "-strip",                # remove metadata (fixes old/unusual JPEGs)
                    "-auto-orient",          # correct EXIF rotation
                    "-resize", f"{width}x>", # resize to width, preserve ratio, no upscale
                    "-quality", "85",
                    abs_path,
                    tmp_path,
                ],
                check=True,
            )
            os.replace(tmp_path, cache_path)  # atomic rename
        except Exception:
            if os.path.exists(tmp_path):
                os.unlink(tmp_path)
            # ImageMagick failed (corrupt/unusual file) — serve original unresized
            return send_file(abs_path)

    return send_file(cache_path, mimetype="image/jpeg")


if __name__ == "__main__":
    print(f"Starting roku-photos server on port {SERVER_PORT}")
    print(f"Serving photos from {LIBRARY_ROOT}")
    app.run(host="0.0.0.0", port=SERVER_PORT)
