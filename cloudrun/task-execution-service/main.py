import os
import base64
import json
import sys
import time
from pprint import pprint
from google.cloud import storage
import jsone

from googleapiclient import discovery
from googleapiclient import errors
from oauth2client.client import GoogleCredentials

from flask import Flask, request, jsonify
from marshmallow import Schema, fields, ValidationError, INCLUDE


app = Flask(__name__)

class CreateTaskRunInputSchema(Schema):
    TASK_NAME = fields.Str(required=True)
    TASK_WORKFLOW_SCRIPT_PATH = fields.Str(required=True)
    TASK_OUTPUT_PATH = fields.Str(required=True)
    TASK_ATTEMPTS_SO_FAR = fields.Str(required=True) 
    TASK_MAX_ATTEMPTS = fields.Str(required=True)
    class Meta:
        unknown = INCLUDE

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
        valid_request_data = task_run_schema.load(request_data['message']['attributes'], unknown=INCLUDE)
    except ValidationError as err:
        print(err.messages)
        return "validation error", 400

    print(valid_request_data) 

    acc = valid_request_data.get('SRA_ACCESSION_NUM')
    print("acc")
    print(acc)

    # check TASK_ATTEMPTS_SO_FAR < TASK_MAX_ATTEMPTS
    # NOT IMPLEMENTED
    
    if int(valid_request_data['TASK_ATTEMPTS_SO_FAR']) < int(valid_request_data['TASK_MAX_ATTEMPTS']):
        valid_request_data['TASK_ATTEMPTS_SO_FAR'] = str(int(valid_request_data['TASK_ATTEMPTS_SO_FAR']) + 1)
        pass
    else:
        return "too many restarts", 204

    # get pipeline template
    storage_client = storage.Client()
    bucket = storage_client.bucket("maximal-dynamo-308105-bowerbird")
    blob = bucket.blob("tasks/singlem/pipeline.json")
    pipeline_imported = blob.download_as_string()
    pipeline_imported_json = json.loads(pipeline_imported)
    print(pipeline_imported_json)

    # prep template
    pipeline_prepped_json = jsone.render(pipeline_imported_json, valid_request_data)
    pipeline_prepped_json["pipeline"]["environment"] = valid_request_data
    print(pipeline_prepped_json)
    

    #send lifesciences api request
    credentials = GoogleCredentials.get_application_default()
    service = discovery.build('lifesciences', 'v2beta', credentials=credentials)
    parent = 'projects/maximal-dynamo-308105/locations/us-central1'

    pipeline_prepped_json["pubSubTopic"] = "projects/maximal-dynamo-308105/topics/bb-core-task-execution-updates"

    pipeline_prepped_json = json.dumps(pipeline_prepped_json)
    
    run_request = service.projects().locations().pipelines().run(parent=parent, body=pipeline_prepped_json)
    run_request_response = run_request.execute()
    print(run_request_response["name"])

    i = 0
    t_end = time.time() + 15
    while time.time() < t_end:
        i = i+1
    #print(i)        
    print("sleep done")
    
    return ("", 204)


@app.route("/taskupdate", methods=["POST"])
def task_update(): 

    print("task update processing started")

    # get request
    request_data = request.data
    type(request_data)
    json_req = json.loads(request_data.decode('utf-8'))
    print(json_req)

    if not request_data:
        msg = "no Pub/Sub message received"
        print(f"error: {msg}")
        return f"Bad Request: {msg}", 400
 
    credentials = GoogleCredentials.get_application_default()
    lifesciences_service = discovery.build('lifesciences', 'v2beta', credentials=credentials)
    operation_path = json_req['message']['attributes']['operation'] 

    #ls_request = service.projects().locations().operations().get(name=parent)
    #response = ls_request.execute()
    #print(response)

    try:
        status_request = lifesciences_service.projects().locations().operations().get(name=operation_path)
        status_response = status_request.execute()
        print(status_response)
    except errors.HttpError as err:
        print('There was an error retrieving the update status. Check the details:')
        print(err._get_reason())

    i = 0
    t_end = time.time() + 5
    while time.time() < t_end:
        i = i+1
    #print(i)        
    print("sleep done")
    
    print("done")

    return ("", 204)

if __name__ == "__main__":
    PORT = int(os.getenv("PORT")) if os.getenv("PORT") else 8080

    # This is used when running locally. Gunicorn is used to run the
    # application on Cloud Run. See entrypoint in Dockerfile.
    app.run(host="127.0.0.1", port=PORT, debug=True)
