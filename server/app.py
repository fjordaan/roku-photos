import os
from flask import Flask, jsonify, send_file, abort, request
from config import LIBRARY_ROOT, SERVER_PORT, NAS_IP, SUPPORTED_EXTENSIONS

app = Flask(__name__)


def iter_photos():
    """Recursively yield all supported photo files under LIBRARY_ROOT."""
    for dirpath, _, filenames in os.walk(LIBRARY_ROOT):
        for filename in sorted(filenames):
            if os.path.splitext(filename)[1].lower() in SUPPORTED_EXTENSIONS:
                yield os.path.join(dirpath, filename)


@app.route("/api/status")
def status():
    return jsonify({"status": "ok"})


@app.route("/api/playlist")
def playlist():
    limit = request.args.get("limit", type=int)
    photos = []
    for abs_path in iter_photos():
        rel_path = os.path.relpath(abs_path, LIBRARY_ROOT)
        # Use forward slashes in URLs regardless of OS
        url_path = rel_path.replace(os.sep, "/")
        photos.append({
            "url": f"http://{NAS_IP}:{SERVER_PORT}/photos/{url_path}",
            "path": url_path,
            "filename": os.path.basename(abs_path),
        })
        if limit and len(photos) >= limit:
            break
    return jsonify(photos)


@app.route("/photos/<path:photo_path>")
def serve_photo(photo_path):
    abs_path = os.path.join(LIBRARY_ROOT, photo_path)
    # Prevent directory traversal attacks
    abs_path = os.path.realpath(abs_path)
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
