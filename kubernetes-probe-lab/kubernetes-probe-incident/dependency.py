from flask import Flask
import time
import os

app = Flask(__name__)

MODE = os.environ.get("MODE", "normal")


@app.route("/health")
def health():
    if MODE == "slow":
        time.sleep(10)

    return "DATABASE OK\n", 200


@app.route("/set-slow")
def set_slow():
    global MODE
    MODE = "slow"
    return "Database is now SLOW\n", 200


@app.route("/set-normal")
def set_normal():
    global MODE
    MODE = "normal"
    return "Database is now NORMAL\n", 200


@app.route("/")
def home():
    return f"Database mode: {MODE}\n"


app.run(host="0.0.0.0", port=8080)
