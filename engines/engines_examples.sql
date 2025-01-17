use test;

create table events3 (
account_id UInt64,
device_id UInt64,
event_type Enum8(
'Login'=1,
'Logout'=2
),
country String,
time_ns UInt64,
date_time DateTime MATERIALIZED toDateTime(time_ns / 1000000000)
) ENGINE = MergeTree()
ORDER BY (account_id);


insert into events3 values(1, 2, 'Login', 'USA', 123451234512345);
insert into events3 values(1, 3, 'Logout', 'USA', 9543211234512345);

SELECT account_id, device_id , event_type , country , time_ns , date_time  from events2;

select partition, name, part_type, partition_id from system.parts
where table='events3';

optimize table events2 final;


create table users  (
	user_id UInt64,
	name String,
	age UInt8,
	country String,
	version Int32
	sign Int8
) Engine = CollapsingMergeTree(sign, version)
ORDER BY user_id;

insert into users values(1, 'Alex', 30, 'Russia', 1);
insert into users values(2, 'Artem', 25, 'Russia', 1);
insert into users values(2, 'Artem', 25, 'Russia', -1);
insert into users values(2, 'Artem', 26, 'Russia', 1);

select * from users final;
optimize table users final;

create table summing_ex (
	id UInt32,
	val1 UInt32,
	val2 String
) Engine = SummingMergeTree(val1)
ORDER BY id;

insert into summing_ex values(1,1,'1') (2,2,'2') (3,3,'3');
insert into summing_ex values(1,2,'2') (2,3,'2') (3,4,'3');

SELECT * from summing_ex final;


create table counters (
	counter_id UInt32
) ENGINE = MergeTree() ORDER BY(counter_id);

create table visits (
	start_date DateTime not null,
	counter_id UInt32,
	count_visits UInt32,
	user_id Nullable(Int32)
) Engine = MergeTree()
ORDER BY (start_date, counter_id);


INSERT INTO visits values('2013-01-01 10:00:00', 1, 5, 4) ('2013-01-02 10:00:00', 1, 45, 3);
INSERT INTO visits values('2013-01-01 10:00:00', 1, 4, 3) ('2013-01-02 10:00:00', 1, 2, 3);
select * from visits;


create table visits_aggregation (
	start_date DateTime not null,
	counter_id UInt32,
	count_visits AggregateFunction(sum, UInt32),
	user_id AggregateFunction(uniq, Nullable(Int32))
) Engine = AggregatingMergeTree()
ORDER BY (start_date, counter_id);

select * from visits_aggregation;

create materialized view mv_visits TO visits_aggregation
as select
	start_date,
	counter_id,
	sumState(count_visits) as count_visits,
	uniqState(user_id) as user_id
from visits
Group by start_date, counter_id;

select start_date, sumMerge(count_visits) as visits, uniqMerge(user_id) as users
from mv_visits
group by start_date
order by start_date ;






