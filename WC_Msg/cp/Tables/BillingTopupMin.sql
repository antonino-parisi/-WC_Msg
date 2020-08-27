CREATE TABLE [cp].[BillingTopupMin] (
    [Currency] CHAR (3)        NOT NULL,
    [Amount]   DECIMAL (19, 7) NOT NULL,
    CONSTRAINT [PK_cp_BillingTopupMin] PRIMARY KEY CLUSTERED ([Currency] ASC)
);

