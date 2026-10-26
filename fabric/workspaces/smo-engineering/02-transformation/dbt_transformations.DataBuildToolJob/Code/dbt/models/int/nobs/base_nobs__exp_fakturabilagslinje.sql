WITH source AS (
    SELECT * FROM {{ source('nobs', 'exp_fakturabilagslinje') }}
),

renamed AS (
    SELECT
        [__kplt__ID]                                       AS pk_invoice_voucher_line_id,
        [_kflt_FakturaID]                                  AS fk_invoice_id,
        TRY_CAST([Antall] AS FLOAT)                        AS quantity,
        [ArtikkelBenevnelse_Intern]                        AS article_name_internal,
        TRY_CAST([EnhetsPris] AS FLOAT)                    AS unit_price,
        TRY_CAST([LinjeBeløp] AS FLOAT)                    AS line_amount,
        TRY_CAST([zz__IsDeleted] AS INT)                   AS is_deleted,
        TRY_CAST([zz__Creation_Timestamp__lxm] AS DATETIME2(6)) AS created_at,
        [zz__Creation_AccountName__lxt]                    AS created_by,
        TRY_CAST([zz__Modification_Timestamp__lxm] AS DATETIME2(6)) AS modified_at,
        [zz__Modification_AccountName__lxt]                AS modified_by,
        TRY_CAST([_ingestion_timestamp] AS DATETIME2(6))      AS ingested_at
    FROM source
)

SELECT *
FROM renamed
WHERE (is_deleted = 0 OR is_deleted IS NULL)
