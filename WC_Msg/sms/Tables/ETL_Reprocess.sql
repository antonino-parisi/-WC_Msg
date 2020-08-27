CREATE TABLE [sms].[ETL_Reprocess] (
    [UMID]          UNIQUEIDENTIFIER NOT NULL,
    [SubAccountUid] INT              NOT NULL,
    [CreatedAt]     DATETIME2 (7)    NOT NULL,
    [UpdatedAt]     DATETIME2 (7)    NULL,
    [Status]        TINYINT          DEFAULT ((0)) NOT NULL,
    [LogType]       VARCHAR (10)     DEFAULT ('sms') NOT NULL,
    [BatchId]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_SmsLog_ETL_Reprocess] PRIMARY KEY NONCLUSTERED ([UMID] ASC),
    CHECK ([LogType]='ipm' OR [LogType]='sms')
);


GO
CREATE NONCLUSTERED INDEX [IX_ETL_Reprocess_BatchId_LogType]
    ON [sms].[ETL_Reprocess]([BatchId] ASC, [LogType] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ETL_Reprocess_Status_CreatedAt]
    ON [sms].[ETL_Reprocess]([Status] ASC, [CreatedAt] DESC);

