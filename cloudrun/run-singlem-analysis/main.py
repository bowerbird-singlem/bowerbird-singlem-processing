import os
from google.cloud import bigquery

from flask import Flask, request

app = Flask(__name__)

@app.route("/", methods=["POST"])
def index():
    
    client = bigquery.Client()

    QUERY = (
        'SELECT acc, mbases, mbytes FROM `maximal-dynamo-308105.singlem.sra_metadata_test1` '
        'WHERE mbases < 500 '
        'LIMIT 2')
    
    query_job = client.query(QUERY)  # API request
    
    rows = query_job.result()  # Waits for query to finish

    for row in rows:
        print(row.acc)

    return ("", 204)


if __name__ == "__main__":
    PORT = int(os.getenv("PORT")) if os.getenv("PORT") else 8080

    # This is used when running locally. Gunicorn is used to run the
    # application on Cloud Run. See entrypoint in Dockerfile.
    app.run(host="127.0.0.1", port=PORT, debug=True)
