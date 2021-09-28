import os
from google.cloud import bigquery
from google.cloud import pubsub_v1

from flask import Flask, request

app = Flask(__name__)

@app.route("/", methods=["POST"])
def index():
    
    client = bigquery.Client()

    project_id = os.getenv('PROJECT')
    print(project_id)

    QUERY = (
        f'SELECT acc, mbases, mbytes FROM `{project_id}.singlem.sra_metadata_test1` '
        'WHERE mbases < 1000 '
        'LIMIT 100')
    
    query_job = client.query(QUERY)  # API request
    
    rows = query_job.result()  # Waits for query to finish
    
    publisher = pubsub_v1.PublisherClient()

    topic = f"projects/{project_id}/topics/bb-core-task-execution-requests"
    print(topic)
    script_path = f"gs://{project_id}-home/bowerbird/tasks/singlem/pipeline.json"
    print(script_path)
    output_path = f"gs://{project_id}-home/bowerbird/outputs/singlem/"
    print(output_path)

    for row in rows:
        future = publisher.publish(topic, 
                b'test', 
                SRA_ACCESSION_NUM=row.acc,
                MBASES = str(row.mbases),
                MBYTES = str(row.mbytes),
                DOWNLOAD_METHOD_ORDER = "aws-http prefetch",
                TASK_NAME = "singlem",
                TASK_WORKFLOW_SCRIPT_PATH = script_path,
                TASK_OUTPUT_PATH = output_path,
                TASK_ATTEMPTS_SO_FAR = str(0),
                TASK_MAX_ATTEMPTS = str(2)
                )
        future.result()
    return ("", 204)


if __name__ == "__main__":
    PORT = int(os.getenv("PORT")) if os.getenv("PORT") else 8080

    # This is used when running locally. Gunicorn is used to run the
    # application on Cloud Run. See entrypoint in Dockerfile.
    app.run(host="127.0.0.1", port=PORT, debug=True)
