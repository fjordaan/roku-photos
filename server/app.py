import os
import sqlite3
from flask import Flask, jsonify, send_file, abort, request
from config import LIBRARY_ROOT, SERVER_PORT, NAS_IP, SUPPORTED_EXTENSIONS, DB_PATH, DEFAULT_PLAYLIST_LIMIT

app = Flask(__name__)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def iter_photos():
    """Recursively yield all supported photo files under LIBRARY_ROOT."""
    for dirpath, _, filenames in os.walk(LIBRARY_ROOT):
        for filename in sorted(filenames):
            if os.path.splitext(filename)[1].lower() in SUPPORTED_EXTENSIONS:
                yield os.path.join(dirpath, filename)


def photo_url(rel_path):
    return f"http://{NAS_IP}:{SERVER_PORT}/photos/{rel_path}"


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@app.route("/api/status")
def status():
    return jsonify({"status": "ok"})


@app.route("/api/playlist")
def playlist():
    order = request.args.get("order", "random")
    limit = request.args.get("limit", DEFAULT_PLAYLIST_LIMIT, type=int)

    # Use SQLite index when available; fall back to filesystem walk on first deploy.
    if os.path.isfile(DB_PATH):
        photos = _playlist_from_db(order, limit)
    else:
        photos = _playlist_from_fs(limit)

    return jsonify(photos)


def _playlist_from_db(order, limit):
    order_clause = "ORDER BY RANDOM()" if order != "az" else "ORDER BY filename"
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    try:
        rows = conn.execute(
            f"SELECT path, filename FROM photos {order_clause} LIMIT ?",
            (limit,),
        ).fetchall()
    finally:
        conn.close()

    return [
        {"url": photo_url(row["path"]), "path": row["path"], "filename": row["filename"]}
        for row in rows
    ]


def _playlist_from_fs(limit):
    photos = []
    for abs_path in iter_photos():
        rel_path = os.path.relpath(abs_path, LIBRARY_ROOT).replace(os.sep, "/")
        photos.append({
            "url": photo_url(rel_path),
            "path": rel_path,
            "filename": os.path.basename(abs_path),
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
    return send_file(abs_path)


if __name__ == "__main__":
    print(f"Starting roku-photos server on port {SERVER_PORT}")
    print(f"Serving photos from {LIBRARY_ROOT}")
    app.run(host="0.0.0.0", port=SERVER_PORT)
