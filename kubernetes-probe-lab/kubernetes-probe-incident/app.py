from flask import Flask
import requests
import time
import os

app = Flask(__name__)

DB_URL = os.environ.get(
    "DB_URL",
    "http://fake-db:8080/health"
)


@app.route("/")
def home():

    start = time.time()

    try:
        response = requests.get(
            DB_URL,
            timeout=15
        )

        elapsed = time.time() - start

        return (
            f"Application response\n"
            f"Database status: {response.status_code}\n"
            f"Database latency: {elapsed:.2f}s\n"
        ), 200

    except Exception as e:

        elapsed = time.time() - start

        return (
            f"Database ERROR\n"
            f"Latency: {elapsed:.2f}s\n"
            f"Error: {str(e)}\n"
        ), 503


@app.route("/live")
def live():

    # IMPORTANT:
    # Liveness checks only the application process.
    # It does NOT call the database.

    return "LIVE\n", 200


@app.route("/ready")
def ready():

    # Readiness checks whether this application
    # can currently serve traffic.

    try:

        response = requests.get(
            DB_URL,
            timeout=2
        )

        if response.status_code == 200:
            return "READY\n", 200

        return "NOT READY\n", 503

    except Exception:

        return "NOT READY\n", 503


@app.route("/health")
def health():

    return "OK\n", 200


app.run(
    host="0.0.0.0",
    port=8080
)
