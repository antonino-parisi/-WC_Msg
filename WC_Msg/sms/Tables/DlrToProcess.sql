CREATE TABLE [sms].[DlrToProcess] (
    [Umid]        UNIQUEIDENTIFIER NOT NULL,
    [StatusId]    TINYINT          NOT NULL,
    [InProcess]   BIT              NOT NULL,
    [CreatedAt]   DATETIME2 (2)    CONSTRAINT [DF_DlrToProcess_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [ScheduledAt] DATETIME2 (2)    CONSTRAINT [DF_DlrToProcess_ScheduledAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_DlrToProcess_Umid] PRIMARY KEY CLUSTERED ([Umid] ASC, [StatusId] ASC),
    CONSTRAINT [FK_DlrToProcess_StatusId] FOREIGN KEY ([StatusId]) REFERENCES [sms].[DimSmsStatus] ([StatusId])
);

