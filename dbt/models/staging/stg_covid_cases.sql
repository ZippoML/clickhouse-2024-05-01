{{
    config(
        engine = 'MergeTree',
        order_by = 'date_rep'
    )
}}

select to_date(date_rep) ass date_rep, cases, deaths from {{source('dbgen', 'src_covid-cases')}}