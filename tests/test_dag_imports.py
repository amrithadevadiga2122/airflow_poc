import os
from airflow.models

import DagBag

def test_dagbag_imports():
    dagbag = DagBag(dag_folder='dags', include_examples=False)
    assert len(dagbag.import_errors) == 0, f"Import errors: {
    dagbag.import_errors
  }"