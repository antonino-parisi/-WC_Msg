CREATE TABLE [sms].[SmsMtScheduled] (
    [Umid]            UNIQUEIDENTIFIER CONSTRAINT [DF_SmsMtScheduled_Umid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [SubAccountUid]   INT              NOT NULL,
    [MSISDN]          BIGINT           NOT NULL,
    [Source]          VARCHAR (20)     NOT NULL,
    [Body]            NVARCHAR (1600)  NOT NULL,
    [DCS]             TINYINT          NOT NULL,
    [CreatedAt]       DATETIME2 (2)    NOT NULL,
    [ScheduledAt]     DATETIME2 (2)    NOT NULL,
    [ExpiryAt]        DATETIME2 (2)    NULL,
    [BatchId]         UNIQUEIDENTIFIER NULL,
    [ClientMessageId] VARCHAR (50)     NULL,
    [ClientBatchId]   VARCHAR (50)     NULL,
    [InProcess]       BIT              CONSTRAINT [DF_SmsMtScheduled_InProcess] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SmsMtScheduled] PRIMARY KEY CLUSTERED ([Umid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_SmsMtScheduled_BatchId_SubAccountUid]
    ON [sms].[SmsMtScheduled]([SubAccountUid] ASC, [BatchId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_SmsMtScheduled_ScheduledAt_InProcess]
    ON [sms].[SmsMtScheduled]([ScheduledAt] ASC, [InProcess] ASC);

