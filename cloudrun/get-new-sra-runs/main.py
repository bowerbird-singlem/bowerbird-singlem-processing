import os
from google.cloud import bigquery
from google.cloud import pubsub_v1

from flask import Flask, request

app = Flask(__name__)

@app.route("/", methods=["POST"])
def index():
    
    client = bigquery.Client()

    QUERY = (
        'SELECT acc, mbases, mbytes FROM `maximal-dynamo-308105.singlem.sra_metadata_test1` '
        'WHERE mbases < 500 '
        'LIMIT 1')
    
    query_job = client.query(QUERY)  # API request
    
    rows = query_job.result()  # Waits for query to finish
    
    publisher = pubsub_v1.PublisherClient()

    for row in rows:
        future = publisher.publish("projects/maximal-dynamo-308105/topics/bb-core-task-execution-requests", 
                b'test', 
                SRA_ACCESSION_NUM=row.acc
                MBASES = row.mbases
                MBYTES = row.mbytes
                TASK_NAME = "singlem"
                TASK_WORKFLOW_SCRIPT_PATH = "gs://bowerbird/workflows/singlem/pipeline.json"
                TASK_OUTPUT_PATH = "gs://bowerbird/workflows/singlem/outputs"
                TASK_ATTEMPTS_SO_FAR = 0
                TASK_MAX_ATTEMPTS = 1
                )
        future.result()
    return ("", 204)


if __name__ == "__main__":
    PORT = int(os.getenv("PORT")) if os.getenv("PORT") else 8080

    # This is used when running locally. Gunicorn is used to run the
    # application on Cloud Run. See entrypoint in Dockerfile.
    app.run(host="127.0.0.1", port=PORT, debug=True)
