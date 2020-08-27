CREATE TABLE [cp].[SecurityEventLog] (
    [Id]              INT              IDENTITY (1, 1) NOT NULL,
    [EventTime]       DATETIME2 (2)    CONSTRAINT [DF_SecurityEventLog_EventTime] DEFAULT (sysutcdatetime()) NOT NULL,
    [EventType]       VARCHAR (50)     NOT NULL,
    [Login]           NVARCHAR (255)   NOT NULL,
    [UserId]          UNIQUEIDENTIFIER NULL,
    [SourceIP]        VARCHAR (50)     NOT NULL,
    [SourceUserAgent] NVARCHAR (1000)  NULL,
    [Payload]         NVARCHAR (4000)  NULL,
    [MapLogin]        NVARCHAR (255)   NULL,
    CONSTRAINT [PK_SecurityEventLog] PRIMARY KEY CLUSTERED ([Id] ASC)
);

