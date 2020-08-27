CREATE TABLE [dbo].[CostSession] (
    [SessionId]       NVARCHAR (250) NOT NULL,
    [Status]          INT            NOT NULL,
    [DateTime]        DATETIME       CONSTRAINT [DF_CostSession_DateTime] DEFAULT (getdate()) NOT NULL,
    [SaveDateTime]    DATETIME       NULL,
    [Iscomprehensive] BIT            NOT NULL,
    CONSTRAINT [PK_CostSession] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);

