import requests
import pandas as pd
from io import StringIO

HOST = 'http://127.0.0.1:8123'

query_ddl = """
    create table http_test (
    a UInt8,
    b String,
    c enum('one' = 1, 'two' = 2)
    ) Engine = MergeTree() ORDER BY a;
"""

query_insert = """
insert into http_test values (1, 'abc', 'one') (2, 'bfd', 'two') (2, 'abfc', 'two') (1, 'abc', 'two')
"""

query_select = """
select * from http_test where c = 'two';
"""

def query(q, host=HOST, conn_timeout = 1500, **kwargs):
    r = requests.post(host, data=q, params=kwargs, timeout=conn_timeout)
    if r.status_code == 200:
        return r.text
    else:
        raise ValueError(r.text)

if __name__ == '__main__':
    data = query(query_select)
    print(data)
    dataframe = pd.read_csv(StringIO(data), sep='\t', names=['a', 'b', 'c'])
    print(dataframe.head())
    print(dataframe.shape)
    print(dataframe.describe())