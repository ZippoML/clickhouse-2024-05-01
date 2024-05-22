SELECT
    (sum(cases) = 27408975) AS assert
FROM {{ ref('f_covid_cases') }}
HAVING assert NOT IN (1)
