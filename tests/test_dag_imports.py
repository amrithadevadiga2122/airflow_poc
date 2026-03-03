from airflow.models import DagBag

def test_dag_imports():
    dagbag = DagBag(dag_folder="dags", include_examples=False)
    # If there are any import errors, build a readable message and fail
    if dagbag.import_errors:
        details = "\n".join(f"- {mod}: {err}" for mod, err in dagbag.import_errors.items())
        raise AssertionError(f"Import errors detected:\n{details}")
    # Ensure at least one DAG is discovered
    assert len(dagbag.dags) > 0, "No DAGs were loaded from the 'dags' folder."