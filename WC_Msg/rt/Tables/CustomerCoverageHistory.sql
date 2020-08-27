CREATE TABLE [rt].[CustomerCoverageHistory] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [SubAccountUid]   INT             NOT NULL,
    [PriceNotifiedAt] SMALLDATETIME   NOT NULL,
    [Country]         CHAR (2)        NOT NULL,
    [OperatorId]      INT             NULL,
    [PriceCurrency]   CHAR (3)        NOT NULL,
    [Price]           DECIMAL (19, 7) NOT NULL,
    CONSTRAINT [PK_CustomerCoverageHistory] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UX_CustomerCoverageHistory] UNIQUE NONCLUSTERED ([SubAccountUid] ASC, [PriceNotifiedAt] ASC, [Country] ASC, [OperatorId] ASC)
);

