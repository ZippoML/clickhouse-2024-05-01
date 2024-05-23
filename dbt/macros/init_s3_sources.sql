{% macro init_s3_sources()-%}

{% set sources = [
    'DROP TABLE IF EXISTS src_covid_cases',
    'CREATE TABLE src_covid_cases (date_rep String,day UInt32,month UInt32,year UInt32,cases UInt32,deaths UInt32,geo_id String) Engine = S3(\'https://storage.yandexcloud.net/ch-data-course/raw_covid__cases.csv\')'
] %}

{% for src in sources %}
    {% set statement = run_query(src) %}
{% endfor %}

{% endmacro -%}
