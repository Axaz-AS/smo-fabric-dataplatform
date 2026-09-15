WITH source AS (
    SELECT * FROM {{ source('excel_mappings', 'nomenklatur') }}
),

cleaned AS (
    SELECT
        TRIM(REPLACE(REPLACE(REPLACE([Nomenklatur_Kode], CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) AS nomenclature_code,
        TRIM(REPLACE(REPLACE(REPLACE([Hovedgruppe], CHAR(13), ''), CHAR(10), ''), CHAR(9), ''))       AS nomenclature_category_code,
        TRIM([Fagområde])                                                                              AS subject_area,
        TRIM([Produktgrupper])                                                                         AS product_group,
        TRIM([Beskrivelse2])                                                                           AS product_sub_group,
        TRIM([Nomenklatur_Tekst])                                                                      AS description,
        CASE TRIM([Tilleggskoder])
            WHEN 'Ja' THEN 1
            WHEN 'Nei' THEN 0
            ELSE NULL
        END                                                                                            AS has_additional_codes,
        TRIM([Fastpris])                                                                               AS price_group,
        TRIM([N/J])                                                                                    AS coverage_type
    FROM source
)

SELECT *
FROM cleaned
WHERE nomenclature_code IS NOT NULL AND nomenclature_code <> ''
