CREATE TABLE [dbo].[PriceChangeAlertData] (
    [AccountId]    NVARCHAR (50)  NOT NULL,
    [SubAccountId] NVARCHAR (50)  NOT NULL,
    [RouteId]      NVARCHAR (50)  NOT NULL,
    [OldPrice]     FLOAT (53)     NOT NULL,
    [NewPrice]     FLOAT (53)     NULL,
    [Active]       BIT            NOT NULL,
    [Operator]     NVARCHAR (200) NOT NULL,
    [SessionId]    NVARCHAR (250) NOT NULL,
    [ExistingCost] FLOAT (53)     NULL,
    [ProposedCost] FLOAT (53)     NULL
);

