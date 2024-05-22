SELECT
    (count(*) = 558) AS assert
FROM {{ ref('f_covid_cases') }}
HAVING assert NOT IN (1)
