from airflow.models

import DagBag

def test_dag_structure():
    dagbag = DagBag(dag_folder='dags', include_examples=False)
    dag = dagbag.get_dag('gcs_to_bq_dataproc_ecommerce')
    assert dag is not None
    # Verify tasks exist
    for task_id in [
        'start',
        'load_products',
        'load_orders',
        'run_dataproc_transform_join',
        'load_sql_from_gcs',
        'assert_query_present',
        'run_bigquery_job',
        'end',
    ]:
        assert task_id in dag.task_ids
    # Verify simple dependencies
    assert dag.get_task('start').downstream_list