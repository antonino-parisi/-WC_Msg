CREATE TABLE [gtn].[CSG_TestNode] (
    [TestNodeUID]     UNIQUEIDENTIFIER NOT NULL,
    [MCC]             SMALLINT         NOT NULL,
    [MNC]             SMALLINT         NOT NULL,
    [OperatorId]      INT              NULL,
    [LastModifiedUtc] DATETIME         CONSTRAINT [DF_CSG_TestNodes_LastModifiedUtc] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_CSG_TestNode] PRIMARY KEY CLUSTERED ([TestNodeUID] ASC)
);

