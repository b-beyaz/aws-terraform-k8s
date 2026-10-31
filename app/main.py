import os
import socket
import time

from flask import Flask, Response, jsonify, request
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

app = Flask(__name__)

VERSION = os.environ.get("APP_VERSION") or "unknown"

REQUESTS = Counter(
    "http_requests_total", "Toplam HTTP isteği", ["method", "path", "status"]
)
LATENCY = Histogram(
    "http_request_duration_seconds", "İstek süresi (saniye)", ["path"]
)


@app.before_request
def start_timer():
    request.start_time = time.time()


@app.after_request
def record_metrics(response):
    if request.path != "/metrics":
        path = request.url_rule.rule if request.url_rule else "unmatched"
        REQUESTS.labels(request.method, path, response.status_code).inc()
        LATENCY.labels(path).observe(time.time() - request.start_time)
    return response


@app.get("/")
def index():
    return jsonify(version=VERSION, pod=socket.gethostname())


@app.get("/health")
def health():
    return jsonify(status="ok")


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)