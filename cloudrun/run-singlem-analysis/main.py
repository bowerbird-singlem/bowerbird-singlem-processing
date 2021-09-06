import os
import base64

from flask import Flask, request

app = Flask(__name__)

@app.route("/", methods=["POST"])
def index():
    
    envelope = request.get_json()
    print(envelope)
    if not envelope:
        msg = "no Pub/Sub message received"
        print(f"error: {msg}")
        return f"Bad Request: {msg}", 400

    if not isinstance(envelope, dict) or "message" not in envelope:
        msg = "invalid Pub/Sub message format"
        print(f"error: {msg}")
        return f"Bad Request: {msg}", 400

    acc = data.get('accession', '')
    print(name)
    #pubsub_message = envelope["accession"]

    #name = "World"
    #if isinstance(pubsub_message, dict) and "data" in pubsub_message:
    #    name = base64.b64decode(pubsub_message["accession"]).decode("utf-8").strip()

    print(f"SRA Accession: {acc}!")

    return ("", 204)


if __name__ == "__main__":
    PORT = int(os.getenv("PORT")) if os.getenv("PORT") else 8080

    # This is used when running locally. Gunicorn is used to run the
    # application on Cloud Run. See entrypoint in Dockerfile.
    app.run(host="127.0.0.1", port=PORT, debug=True)
