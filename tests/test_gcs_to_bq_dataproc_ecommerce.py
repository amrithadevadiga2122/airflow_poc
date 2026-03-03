from airflow.models import DagBag

def _load_dagbag():
    # Avoid DB access so tests stay fast and deterministic
    try:
        return DagBag(dag_folder="dags", include_examples=False, read_dags_from_db=False)
    except TypeError:
        # Older Airflow versions don’t support read_dags_from_db
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

    # Use task-level upstream/downstream sets (no metastore calls)
    t_transform = dag.get_task("run_dataproc_transform_join")
    assert set(t_transform.upstream_task_ids) == {"load_products", "load_orders"}
    assert "load_sql_from_gcs" in t_transform.downstream_task_ids

    t_load_sql = dag.get_task("load_sql_from_gcs")
    assert "assert_query_present" in t_load_sql.downstream_task_ids

    t_assert = dag.get_task("assert_query_present")
    assert "run_bigquery_job" in t_assert.downstream_task_ids

    t_bq = dag.get_task("run_bigquery_job")
    assert "end" in t_bq.downstream_task_ids