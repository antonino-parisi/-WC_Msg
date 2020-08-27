CREATE TABLE [dbo].[MessageStats] (
    [AccountId]    NVARCHAR (50)   NOT NULL,
    [SubAccountId] NVARCHAR (50)   NOT NULL,
    [MessageType]  NVARCHAR (50)   NOT NULL,
    [RouteId]      NVARCHAR (50)   NOT NULL,
    [Price]        DECIMAL (18, 5) NOT NULL,
    [TotalMessage] INT             NOT NULL,
    [date]         DATE            NOT NULL,
    [country]      VARCHAR (128)   NOT NULL,
    [Cost]         DECIMAL (18, 5) CONSTRAINT [DF_MessageStats_Cost] DEFAULT ((0)) NOT NULL,
    [Error]        INT             NOT NULL,
    [Pending]      INT             CONSTRAINT [DF_MessageStats_Pending] DEFAULT ((0)) NOT NULL,
    [Rejected]     INT             CONSTRAINT [DF_MessageStats_Rejected] DEFAULT ((0)) NOT NULL,
    [Sent]         INT             CONSTRAINT [DF_MessageStats_Sent] DEFAULT ((0)) NOT NULL,
    [OperatorName] NVARCHAR (50)   CONSTRAINT [DF_MessageStats_OperatorId] DEFAULT (N'unknown') NOT NULL,
    CONSTRAINT [PK_MessageStats] PRIMARY KEY CLUSTERED ([SubAccountId] ASC, [MessageType] ASC, [RouteId] ASC, [date] ASC, [country] ASC, [OperatorName] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_MessageStats]
    ON [dbo].[MessageStats]([date] ASC, [country] ASC)
    INCLUDE([AccountId], [SubAccountId], [MessageType], [RouteId], [Price], [TotalMessage], [Cost], [Error], [Pending], [Rejected], [Sent], [OperatorName]);

