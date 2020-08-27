CREATE TABLE [dbo].[RouteSelSessionData] (
    [AccountId]    NVARCHAR (50)  NOT NULL,
    [SubAccountId] NVARCHAR (50)  NOT NULL,
    [RouteId]      NVARCHAR (50)  NOT NULL,
    [Operator]     NVARCHAR (200) NOT NULL,
    [SessionId]    NVARCHAR (250) NOT NULL,
    [DateTime]     DATETIME       CONSTRAINT [DF_RouteSelSessionData_DateTime] DEFAULT (getdate()) NOT NULL,
    [Status]       INT            NOT NULL
);

