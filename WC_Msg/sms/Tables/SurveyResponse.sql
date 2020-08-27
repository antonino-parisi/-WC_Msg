CREATE TABLE [sms].[SurveyResponse] (
    [UMID]         UNIQUEIDENTIFIER NOT NULL,
    [StartedAt]    DATETIME2 (2)    NOT NULL,
    [FinishedAt]   DATETIME2 (2)    NOT NULL,
    [ResponseJson] NVARCHAR (3000)  NOT NULL,
    [FillTime]     INT              CONSTRAINT [DF_SurveyResponse_FillTime] DEFAULT ((0)) NOT NULL,
    [CampaignId]   INT              NULL,
    [SurveyUid]    INT              NULL,
    CONSTRAINT [PK_SurveyResponse] PRIMARY KEY CLUSTERED ([UMID] ASC),
    CONSTRAINT [FK_SurveyResponse_SurveyResponse] FOREIGN KEY ([UMID]) REFERENCES [sms].[SurveyResponse] ([UMID])
);


GO
CREATE NONCLUSTERED INDEX [IX_SurveyResponse_CampaignId]
    ON [sms].[SurveyResponse]([CampaignId] ASC);

