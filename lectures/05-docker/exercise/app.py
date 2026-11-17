"""Tea-time special: a one-page service for the staff room (ORD-371)."""

from flask import Flask

app = Flask(__name__)


@app.get("/")
def special():
    return "Tea-time special: flat white and a flapjack for 3.50 pounds\n"
