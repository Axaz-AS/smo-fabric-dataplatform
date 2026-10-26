CREATE TABLE [mart].[agg_gapvision_pbi_score_monthly] (
    [company_id]        INT           NULL,
    [measurement]       VARCHAR (255) NULL,
    [measurement_group] VARCHAR (255) NULL,
    [question]          VARCHAR (500) NULL,
    [score_month]       DATE          NULL,
    [total_responses]   INT           NULL,
    [average_score]     FLOAT (53)    NULL,
    [min_score]         FLOAT (53)    NULL,
    [max_score]         FLOAT (53)    NULL
);


GO