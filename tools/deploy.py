"""
deploy.py — Package and sideload the Roku app.

Usage: python3 tools/deploy.py
"""

import os
import sys
import zipfile
import urllib.request
import urllib.parse

ROKU_IP   = "192.168.1.181"
ROKU_USER = "rokudev"
ROKU_PASS = "celery"

APP_DIR = os.path.join(os.path.dirname(__file__), "..", "roku-app")
ZIP_OUT = os.path.join(os.path.dirname(__file__), "..", "out", "roku-deploy.zip")


def build_zip():
    os.makedirs(os.path.dirname(ZIP_OUT), exist_ok=True)
    with zipfile.ZipFile(ZIP_OUT, "w", zipfile.ZIP_DEFLATED) as zf:
        for dirpath, _, files in os.walk(APP_DIR):
            for f in files:
                abs_path = os.path.join(dirpath, f)
                arc_name = os.path.relpath(abs_path, APP_DIR).replace(os.sep, "/")
                zf.write(abs_path, arc_name)
                print(f"  {arc_name}")
    print(f"Zip built: {ZIP_OUT}")


def sideload():
    import subprocess
    result = subprocess.run([
        "curl", "--digest",
        "-o", "-",
        "-w", "\nHTTP %{http_code}\n",
        "-F", "mysubmit=Delete",
        "-F", f"archive=@{ZIP_OUT}",
        "--user", f"{ROKU_USER}:{ROKU_PASS}",
        f"http://{ROKU_IP}/plugin_install",
    ], capture_output=True, text=True)
    if "Install Success" in result.stdout or "install_success" in result.stdout.lower():
        print("Sideload: Install Success")
    else:
        print("Sideload output:", result.stdout[-500:])
        print("Stderr:", result.stderr[-200:])
        sys.exit(1)


if __name__ == "__main__":
    print("Building zip...")
    build_zip()
    print("Sideloading...")
    sideload()
    print("Done.")
