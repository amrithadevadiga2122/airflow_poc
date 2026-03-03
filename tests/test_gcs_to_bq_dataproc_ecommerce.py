from airflow.models import DagBag

def _load_dagbag():
    # Prefer not to read from DB; fall back for older Airflow versions
    try:
        return DagBag(dag_folder="dags", include_examples=False, read_dags_from_db=False)
    except TypeError:
        return DagBag(dag_folder="dags", include_examples=False)

def test_gcs_to_bq_dataproc_ecommerce_tasks():
    dagbag = _load_dagbag()
    dag = dagbag.dags.get("gcs_to_bq_dataproc_ecommerce")
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

    # Basic dependency checks using in-memory graph (no DB access)
    assert {"load_products", "load_orders"}.issubset(dag.upstream_task_ids("run_dataproc_transform_join"))
    assert "load_sql_from_gcs" in dag.downstream_task_ids("run_dataproc_transform_join")
    assert "assert_query_present" in dag.downstream_task_ids("load_sql_from_gcs")
    assert "run_bigquery_job" in dag.downstream_task_ids("assert_query_present")
    assert "end" in dag.downstream_task_ids("run_bigquery_job")