CREATE TABLE [sms].[SurveyBatch] (
    [BatchId]                          UNIQUEIDENTIFIER NOT NULL,
    [SurveyUid]                        INT              NOT NULL,
    [CreatedAt]                        DATETIME2 (2)    NOT NULL,
    [MessagesCount]                    INT              CONSTRAINT [DF_SurveyBatch_MessagesCount] DEFAULT ((0)) NOT NULL,
    [AcceptedCount]                    INT              CONSTRAINT [DF_SurveyBatch_AcceptedCount] DEFAULT ((0)) NOT NULL,
    [RejectedCount]                    INT              CONSTRAINT [DF_SurveyBatch_RejectedCount] DEFAULT ((0)) NOT NULL,
    [MessageClickedCount]              INT              NULL,
    [AverageClickTimeInSec]            INT              NULL,
    [ResponseReceivedCount]            INT              NULL,
    [AverageResponseReceivedTimeInSec] INT              NULL,
    CONSTRAINT [PK_SurveyBatch] PRIMARY KEY CLUSTERED ([BatchId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_SurveyBatch_SurveyUid_CreatedAt]
    ON [sms].[SurveyBatch]([SurveyUid] ASC, [CreatedAt] ASC)
    INCLUDE([BatchId]);

