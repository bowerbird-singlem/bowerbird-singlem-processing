import os
import base64
import json
import sys
import time
from pprint import pprint

from googleapiclient import discovery
from oauth2client.client import GoogleCredentials

from flask import Flask, request, jsonify
from marshmallow import Schema, fields, ValidationError


app = Flask(__name__)

class CreateTaskRunInputSchema(Schema):
    accession = fields.Str(required=True)

@app.route("/newtask", methods=["POST"])
def new_task():

    print("new task processing started")
    # get request
    request_data = request.get_json() 

    if not request_data:
        msg = "no Pub/Sub message received"
        print(f"error: {msg}")
        return f"Bad Request: {msg}", 400

    if not isinstance(request_data, dict) or "message" not in request_data:
        msg = "invalid Pub/Sub message format"
        print(f"error: {msg}")
        return f"Bad Request: {msg}", 400

    # validate request 
    task_run_schema = CreateTaskRunInputSchema() 
    try:
        valid_request_data = task_run_schema.load(request_data['message']['attributes'])
    except ValidationError as err:
        return jsonify(err.messages), 400

    print(valid_request_data) 

    acc = valid_request_data.get('accession')
    print("acc")
    print(acc)

    credentials = GoogleCredentials.get_application_default()
    service = discovery.build('lifesciences', 'v2beta', credentials=credentials)
    parent = 'projects/maximal-dynamo-308105/locations/us-central1'

    with open(os.path.join(sys.path[0], "pipeline.json"), "r") as f:
        run_pipeline_request_body = json.load(f)

    run_pipeline_request_body["pipeline"]["environment"]["SRA_ACCESSION_NUM"] = acc
    run_pipeline_request_body["pubSubTopic"] = "projects/maximal-dynamo-308105/topics/bb-core-task-execution-updates"

    ls_request = service.projects().locations().pipelines().run(parent=parent, body=run_pipeline_request_body)
    response = ls_request.execute()

    print(response["name"])
    
    i = 0
    t_end = time.time() + 15
    while time.time() < t_end:
            i = i+1
    print(i)        
    print("sleep done")
    
    return ("", 204)


@app.route("/taskupdate", methods=["POST"])
def task_update(): 

    print("task update processing started")

    # get request
    request_data = request.data

    if not request_data:
        msg = "no Pub/Sub message received"
        print(f"error: {msg}")
        return f"Bad Request: {msg}", 400

    if not isinstance(request_data, dict) or "message" not in request_data:
        msg = "invalid Pub/Sub message format"
        print(f"error: {msg}")
        return f"Bad Request: {msg}", 400
    
    request_data = request.form.get('done')
    
    i = 0
    t_end = time.time() + 5
    while time.time() < t_end:
        i = i+1
    print(i)        
    print("sleep done")
    
    print("done")

    return ("", 204)

if __name__ == "__main__":
    PORT = int(os.getenv("PORT")) if os.getenv("PORT") else 8080

    # This is used when running locally. Gunicorn is used to run the
    # application on Cloud Run. See entrypoint in Dockerfile.
    app.run(host="127.0.0.1", port=PORT, debug=True)
