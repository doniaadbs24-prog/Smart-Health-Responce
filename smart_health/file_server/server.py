"""
SHR file server — graduation-project replacement for Firebase Storage.

Saves uploaded files under ./uploads/<subpath>/<filename> and returns a
relative path in JSON. Firestore stores only that relative path; the Flutter
client prepends AppConfig.apiBaseUrl when displaying.
"""
import os
import posixpath
from pathlib import Path
from flask import Flask, request, jsonify, send_from_directory, abort
from werkzeug.utils import secure_filename

BASE_DIR = Path(__file__).resolve().parent
UPLOAD_ROOT = BASE_DIR / "uploads"
UPLOAD_ROOT.mkdir(exist_ok=True)

# 25 MB cap — generous for profile photos / certificate PDFs / case images.
MAX_UPLOAD_BYTES = 25 * 1024 * 1024

app = Flask(__name__)
app.config["MAX_CONTENT_LENGTH"] = MAX_UPLOAD_BYTES


def _safe_subpath(subpath: str) -> Path:
    """Reject path-traversal attempts. Returns an absolute Path inside UPLOAD_ROOT."""
    # Use posixpath so normalisation keeps forward slashes on every OS.
    cleaned = posixpath.normpath("/" + subpath).lstrip("/")
    target = (UPLOAD_ROOT / cleaned).resolve()
    root = UPLOAD_ROOT.resolve()
    if root not in target.parents and target != root:
        abort(400, description="invalid path")
    return target


@app.get("/health")
def health():
    return jsonify(status="ok"), 200


@app.post("/upload/<path:subpath>")
def upload(subpath: str):
    if "file" not in request.files:
        return jsonify(error="missing 'file' multipart field"), 400
    f = request.files["file"]
    if not f or f.filename == "":
        return jsonify(error="empty filename"), 400

    # Preserve the file extension from the upload, sanitise the leaf name.
    original = secure_filename(f.filename) or "file"
    ext = Path(original).suffix  # ".jpg", ".pdf", ...

    # The endpoint's subpath becomes the on-disk parent directory.
    # Example: subpath = "users/abc123/profile" → save profile<ext> under users/abc123/.
    parent_subpath, _, leaf = subpath.rpartition("/")
    leaf = secure_filename(leaf) or "file"
    parent_dir = _safe_subpath(parent_subpath) if parent_subpath else UPLOAD_ROOT
    parent_dir.mkdir(parents=True, exist_ok=True)

    saved_name = f"{leaf}{ext}"
    saved_path = parent_dir / saved_name
    f.save(saved_path)

    rel = saved_path.relative_to(UPLOAD_ROOT).as_posix()
    return jsonify(path=f"/uploads/{rel}"), 200


@app.get("/uploads/<path:filepath>")
def serve(filepath: str):
    target = _safe_subpath(filepath)
    if not target.is_file():
        abort(404)
    return send_from_directory(target.parent, target.name)


@app.delete("/uploads/<path:filepath>")
def delete(filepath: str):
    target = _safe_subpath(filepath)
    if not target.is_file():
        return ("", 404)
    target.unlink()
    return ("", 204)


@app.errorhandler(413)
def too_large(_e):
    return jsonify(error=f"file exceeds {MAX_UPLOAD_BYTES} bytes"), 413


if __name__ == "__main__":
    # Bind to 0.0.0.0 so phones / emulators on the LAN can reach it.
    # Port 5000 matches AppConfig.apiBaseUrl.
    app.run(host="0.0.0.0", port=5000, debug=True)
