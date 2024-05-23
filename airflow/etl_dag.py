from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from apache.airflow.providers.clickhouse.hooks.ClickhouseHook import ClickhouseHook
from apache.airflow.providers.clickhouse.operators.ClickhouseOperator import ClickhouseOperator


def transfer():
    pg_hook = PostgresHook(postgres_conn_id='pg_conn_id', database='etl')
    ch_hook = ClickhouseHook(click_conn_id='ch_conn_id', database='etl')
    records = pg_hook.get_records('select * from sales where event_date = {{ds}}')
    ch_hook.run("insert into sales values", records)
    print('transfer from postgres')


with DAG(dag_id='etl_dag', start_date=datetime(2024,5, 23), catchup=False) as dag:
    PythonOperator(task_id='transfer_task', python_callable=transfer) >> ClickhouseOperator(
        task_id='aggregate_data', sql="""
            insert into aggr_sales
            SELECT event_date, sum(qty*price) from sales
            GROUP BY event_date
            HAVING event_date = {{ds}}
        """
    ) >> ClickhouseOperator(
        task_id='select_data', sql="""
            select sum_income from aggr_sales where event_date = {{ds}};
        """
    ) >> PythonOperator(task_id='log_result',
                        python_callable=lambda task_instance: print(task_instance.ecom_pull(task_id='select_data', key='return_value')))