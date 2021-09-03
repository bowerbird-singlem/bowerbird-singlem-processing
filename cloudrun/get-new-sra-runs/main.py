import os
from google.cloud import bigquery

from flask import Flask, request

app = Flask(__name__)

@app.route("/", methods=["POST"])
def index():
    #client = bigquery.Client()

    # Perform a query.
    #QUERY = (
    #    'SELECT name FROM `bigquery-public-data.usa_names.usa_1910_2013` '
    #    'WHERE state = "TX" '
    #    'LIMIT 3')
    #query_job = client.query(QUERY)  # API request
    #rows = query_job.result()  # Waits for query to finish

    #for row in rows:
    #    print(row.name)

    return ("", 204)


if __name__ == "__main__":
    PORT = int(os.getenv("PORT")) if os.getenv("PORT") else 8080

    # This is used when running locally. Gunicorn is used to run the
    # application on Cloud Run. See entrypoint in Dockerfile.
    app.run(host="127.0.0.1", port=PORT, debug=True)
