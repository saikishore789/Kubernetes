from flask import Flask
import os
import time

app = Flask(__name__)

healthy = True
ready = True
delay = 0


@app.route("/")
def home():
    if delay > 0:
        time.sleep(delay)

    return "Hello from Kubernetes\n"


@app.route("/live")
def live():
    if not healthy:
        return "Application is unhealthy\n", 500

    return "LIVE\n", 200


@app.route("/ready")
def ready_probe():
    if not ready:
        return "Application is NOT READY\n", 503

    return "READY\n", 200


@app.route("/make-unhealthy")
def make_unhealthy():
    global healthy
    healthy = False
    return "Application is now unhealthy\n"


@app.route("/make-healthy")
def make_healthy():
    global healthy
    healthy = True
    return "Application is healthy\n"


@app.route("/make-not-ready")
def make_not_ready():
    global ready
    ready = False
    return "Application is now NOT READY\n"


@app.route("/make-ready")
def make_ready():
    global ready
    ready = True
    return "Application is READY\n"


@app.route("/slow/<int:seconds>")
def make_slow(seconds):
    global delay
    delay = seconds
    return f"Application delay set to {seconds} seconds\n"


@app.route("/normal")
def normal():
    global delay
    delay = 0
    return "Application returned to normal\n"


app.run(host="0.0.0.0", port=8080)