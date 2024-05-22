import datetime
import time
import psutil
from infi.clickhouse_orm import Database

from clients_examples.models import CPUStat, CPUStatBuffer

db = Database('default')
db.create_table(CPUStat)
db.create_table(CPUStatBuffer)

while True:
    time.sleep(1)
    timestamp = datetime.datetime.now()
    stats = psutil.cpu_percent(percpu=True)
    print(stats)
    result = []
    for i in range(len(stats)):
        cpu_stat = CPUStatBuffer(timestamp=timestamp, cpu_id=i, cpu_percent=stats[i])
        result.append(cpu_stat)
    db.insert(result)
