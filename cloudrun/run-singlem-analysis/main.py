import os
import base64
import json
import sys
from pprint import pprint

from googleapiclient import discovery
from oauth2client.client import GoogleCredentials

from flask import Flask, request

app = Flask(__name__)

@app.route("/", methods=["POST"])
def index():
    
    envelope = request.get_json()
    if not envelope:
        msg = "no Pub/Sub message received"
        print(f"error: {msg}")
        return f"Bad Request: {msg}", 400

    if not isinstance(envelope, dict) or "message" not in envelope:
        msg = "invalid Pub/Sub message format"
        print(f"error: {msg}")
        return f"Bad Request: {msg}", 400

    acc = envelope.get('message', '').get('attributes', '').get('accession', '')

    #if isinstance(pubsub_message, dict) and "data" in pubsub_message:
    #    name = base64.b64decode(pubsub_message["accession"]).decode("utf-8").strip()

    print(f"SRA Accession: {acc}")

    credentials = GoogleCredentials.get_application_default()
    service = discovery.build('lifesciences', 'v2beta', credentials=credentials)
    parent = 'projects/maximal-dynamo-308105/locations/us-central1'

    with open(os.path.join(sys.path[0], "pipeline.json"), "r") as f:
        run_pipeline_request_body = json.load(f)
    
    run_pipeline_request_body["pipeline"]["environment"]["ACCESSION"] = acc

    ls_request = service.projects().locations().pipelines().run(parent=parent, body=run_pipeline_request_body)
    response = ls_request.execute()

    pprint(response["pipeline"]["environment"]["ACCESSION"])
    
    return ("", 204)


if __name__ == "__main__":
    PORT = int(os.getenv("PORT")) if os.getenv("PORT") else 8080

    # This is used when running locally. Gunicorn is used to run the
    # application on Cloud Run. See entrypoint in Dockerfile.
    app.run(host="127.0.0.1", port=PORT, debug=True)
