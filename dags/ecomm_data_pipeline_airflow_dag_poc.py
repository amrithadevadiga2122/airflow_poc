# DAG: Load JSON from GCS to BigQuery, run Dataproc Serverless transform, then run a SQL script (stored in GCS) in BigQuery.

from airflow.decorators import dag
from airflow.models import Variable
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.providers.google.cloud.operators.dataproc import DataprocCreateBatchOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.providers.google.cloud.hooks.gcs import GCSHook
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from pendulum import datetime
from jinja2 import Template
import uuid
import os

@dag(
    dag_id="gcs_to_bq_dataproc_ecommerce",
    description=(
     
        "Load products & orders JSON from GCS into BigQuery (overwrite), "
        "then run a Dataproc Serverless PySpark batch to transform/join "
        "and append to enriched_orders, and finally execute a SQL stored in GCS."
    ),
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    tags=["poc", "gcs", "bigquery", "dataproc", "ecommerce"],
)
def gcs_to_bq_dataproc_ecommerce():
    """
    DAG:
      1) Load products.json -> bigquery.products (overwrite)
      2) Load orders.json   -> bigquery.orders (overwrite)
      3) Run Dataproc Serverless PySpark job to build bigquery.enriched_orders (append)
      4) Load parameterized SQL from GCS and execute in BigQuery to build filtered table
    """

    # ------------------------------ Config ---------------------------------
    project_id = Variable.get("gcp_project_id", default_var="prj-aidataandanalytics-s-24362" )

    dataset = Variable.get("bq_dataset", default_var="retail_data_poc")

    bucket = Variable.get("raw_bucket", default_var="airflow-cicd-poc")
    temp_bucket = Variable.get("temp_bucket", default_var="airflow-cicd-poc-tmp")

    GCP_CONN_ID = Variable.get("gcp_conn_id", default_var="google_cloud_default")

 
    bq_location = Variable.get("bq_location", default_var="us-central1")

    dataproc_region = Variable.get("dataproc_region", default_var="us-central1")
    dataproc_runtime_version = Variable.get("dataproc_runtime_version", default_var="2.2")

    dataproc_sa = Variable.get("dataproc_service_account", default_var="726220205777-compute@developer.gserviceaccount.com")
    network_uri = Variable.get("dataproc_network_uri", default_var="projects/prj-aidataandanalytics-s-24362/global/networks/dmi-network")
    subnetwork_uri = Variable.get("dataproc_subnetwork_uri", default_var="projects/prj-aidataandanalytics-s-24362/regions/us-central1/subnetworks/dmi-network")

    products_src = "products/products.json"
    orders_src = "orders/orders.json"

    transform_script_gcs = f"gs://{bucket}/scripts/transform_join_ecommerce.py"

    sql_bucket = Variable.get("sql_bucket", default_var=bucket)
    sql_object = Variable.get("sql_object", default_var="scripts/filtered.sql")

    source_table_after_transform = "enriched_orders"
    filtered_target_table = "filtered_orders"

    # ---------------------- Load & render SQL from GCS ----------------------
    def _load_sql_from_gcs(ti, project_id, dataset, source_table, target_table, **_):
        """
        Download SQL from GCS, render Jinja placeholders with given params,
        and push the rendered SQL to XCom (key='sql_text_rendered').
        Ensure your SQL file uses '>' and not '&gt;'.
        """
        hook = GCSHook(gcp_conn_id=GCP_CONN_ID)
        data = hook.download(bucket_name=sql_bucket, object_name=sql_object)
        sql_text = data.decode("utf-8") if isinstance(data, (bytes, bytearray)) else str(data)

        if not sql_text.strip():
            raise ValueError(f"SQL file gs://{sql_bucket}/{sql_object} is empty.")

        rendered_sql = Template(sql_text).render(
            params={
                "project": project_id,
                "dataset": dataset,
                "source_table": source_table,
                "target_table": target_table,
            }
        )
        # quick preview to verify params were injected
        print("Rendered SQL preview:", rendered_sql[:300].replace("\n", " "))
        ti.xcom_push(key="sql_text_rendered", value=rendered_sql)

    start = BashOperator(task_id="start", bash_command='echo "Job Started.."')

    load_products = GCSToBigQueryOperator(
        task_id="load_products",
        gcp_conn_id=GCP_CONN_ID,
        bucket=bucket,
        source_objects=[products_src],
        destination_project_dataset_table=f"{project_id}.{dataset}.products",
        source_format="NEWLINE_DELIMITED_JSON",
        write_disposition="WRITE_TRUNCATE",
        autodetect=True,
        location=bq_location,
    )

    load_orders = GCSToBigQueryOperator(
        task_id="load_orders",
        gcp_conn_id=GCP_CONN_ID,
        bucket=bucket,
        source_objects=[orders_src],
        destination_project_dataset_table=f"{project_id}.{dataset}.orders",
        source_format="NEWLINE_DELIMITED_JSON",
        write_disposition="WRITE_TRUNCATE",
        autodetect=True,
        location=bq_location,
    )

    batch_id = f"ecom-transform-{str(uuid.uuid4())[:8]}"

    run_dataproc = DataprocCreateBatchOperator(
        task_id="run_dataproc_transform_join",
        gcp_conn_id=GCP_CONN_ID,
        project_id=project_id,
        region=dataproc_region,
        batch={
            "pyspark_batch": {
                "main_python_file_uri": transform_script_gcs,
                "args": ["--project", project_id, "--dataset", dataset, "--temp_bucket", f"gs://{temp_bucket}"],
                "jar_file_uris": [],
            },
            "runtime_config": {"version": dataproc_runtime_version},
            "environment_config": {
                "execution_config": {
                    "service_account": dataproc_sa,
                    "network_uri": network_uri,
                    "subnetwork_uri": subnetwork_uri,
                }
            },
        },
        batch_id=batch_id,
    )

    load_sql = PythonOperator(
        task_id="load_sql_from_gcs",
        python_callable=_load_sql_from_gcs,
        op_kwargs={
            "project_id": project_id,
            "dataset": dataset,
            "source_table": source_table_after_transform,
            "target_table": filtered_target_table,
        },
    )

    #early guard to fail if query is empty
    def _assert_query_present(ti, **_):
        q = ti.xcom_pull(task_ids="load_sql_from_gcs", key="sql_text_rendered")
        if not q or not str(q).strip():
            raise ValueError("Rendered SQL is empty or None. Aborting before BigQuery job.")
    assert_query_present = PythonOperator(task_id="assert_query_present", python_callable=_assert_query_present)

    run_bq = BigQueryInsertJobOperator(
        task_id="run_bigquery_job",
        gcp_conn_id=GCP_CONN_ID,
        location=bq_location,
        configuration={
            "query": {
            
                "query": "{{ ti.xcom_pull(task_ids='load_sql_from_gcs', key='sql_text_rendered') }}",  # <-- FIXED
                "useLegacySql": False,
                "priority": "INTERACTIVE",
            }
        },
    )

    end = BashOperator(task_id="end", bash_command='echo "Job Done !!!"')

    start >> [load_products, load_orders] >> run_dataproc >> load_sql >> assert_query_present >> run_bq >> end

dag = gcs_to_bq_dataproc_ecommerce()