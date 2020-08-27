CREATE TABLE [sms].[JobCalculate] (
    [JobId]          INT           IDENTITY (1, 1) NOT NULL,
    [TimeframeStart] SMALLDATETIME NOT NULL,
    [TimeframeEnd]   SMALLDATETIME NOT NULL,
    [SubAccountUid]  INT           NULL,
    [Country]        CHAR (2)      NULL,
    [OperatorId]     INT           NULL,
    [CreatedAt]      DATETIME2 (2) CONSTRAINT [DF_JobCalculate_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [StartedAt]      DATETIME2 (2) NULL,
    [CompletedAt]    DATETIME2 (2) NULL,
    CONSTRAINT [PK_JobCalculate] PRIMARY KEY CLUSTERED ([JobId] ASC)
);

