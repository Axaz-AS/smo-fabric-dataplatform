CREATE TABLE [core].[core_gapvision_score] (
    [company_id]         INT           NULL,
    [response_id]        INT           NULL,
    [measurement]        VARCHAR (255) NULL,
    [event_name]         VARCHAR (255) NULL,
    [measurement_group]  VARCHAR (255) NULL,
    [sorting]            INT           NULL,
    [answer_date]        DATE          NULL,
    [question]           VARCHAR (500) NULL,
    [answer_text]        VARCHAR (500) NULL,
    [score]              FLOAT (53)    NULL,
    [sendout_at]         DATETIME2 (6) NULL,
    [answered_at]        DATETIME2 (6) NULL,
    [external_reference] VARCHAR (255) NULL,
    [respondent_comment] VARCHAR (MAX) NULL
);


GO