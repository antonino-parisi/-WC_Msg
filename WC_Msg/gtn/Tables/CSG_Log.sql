CREATE TABLE [gtn].[CSG_Log] (
    [TransactionId]     UNIQUEIDENTIFIER NOT NULL,
    [RouteId]           VARCHAR (50)     NOT NULL,
    [OperatorId]        INT              NOT NULL,
    [TestCase]          VARCHAR (50)     NULL,
    [StatusId]          SMALLINT         NOT NULL,
    [CreatedTimeUtc]    DATETIME         CONSTRAINT [DF_CSG_Logs_CreatedTimeUtc] DEFAULT (getutcdate()) NOT NULL,
    [TestResultJson]    NVARCHAR (4000)  NULL,
    [TestResultRawJson] NVARCHAR (4000)  NULL,
    [ClientPayload]     NVARCHAR (4000)  NULL,
    CONSTRAINT [PK_CSG_Log] PRIMARY KEY CLUSTERED ([TransactionId] ASC)
);

