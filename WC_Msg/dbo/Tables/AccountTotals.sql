CREATE TABLE [dbo].[AccountTotals] (
    [SubAccountId] NVARCHAR (50) NOT NULL,
    [MessageType]  VARCHAR (50)  NOT NULL,
    [Date]         DATETIME      NOT NULL,
    [Total]        INT           NOT NULL,
    CONSTRAINT [PK_AccountTotals] PRIMARY KEY CLUSTERED ([SubAccountId] ASC, [MessageType] ASC, [Date] ASC)
);

