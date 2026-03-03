from airflow.models import DagBag

def test_gcs_to_bq_dataproc_ecommerce_tasks():
    dagbag = DagBag(dag_folder="dags", include_examples=False)
    dag = dagbag.get_dag("gcs_to_bq_dataproc_ecommerce")
    assert dag is not None, "DAG 'gcs_to_bq_dataproc_ecommerce' not found."

    expected_tasks = {
        "start",
        "load_products",
        "load_orders",
        "run_dataproc_transform_join",
        "load_sql_from_gcs",
        "assert_query_present",
        "run_bigquery_job",
        "end",
    }
    assert expected_tasks.issubset(set(dag.task_ids)), f"Missing tasks: {expected_tasks - set(dag.task_ids)}"

    # Basic dependency checks
    assert "run_dataproc_transform_join" in dag.get_task("load_products").downstream_task_ids
    assert "run_dataproc_transform_join" in dag.get_task("load_orders").downstream_task_ids
    assert "load_sql_from_gcs" in dag.get_task("run_dataproc_transform_join").downstream_task_ids
    assert "assert_query_present" in dag.get_task("load_sql_from_gcs").downstream_task_ids
    assert "run_bigquery_job" in dag.get_task("assert_query_present").downstream_task_ids
    assert "end" in dag.get_task("run_bigquery_job").downstream_task_ids