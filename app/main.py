import os
import socket

from flask import Flask, jsonify

app = Flask(__name__)

VERSION = os.environ.get("APP_VERSION") or "unknown"


@app.get("/")
def index():
    return jsonify(version=VERSION, pod=socket.gethostname())


@app.get("/health")
def health():
    return jsonify(status="ok")