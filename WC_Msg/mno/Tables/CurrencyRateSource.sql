CREATE TABLE [mno].[CurrencyRateSource] (
    [id]            INT              IDENTITY (1, 1) NOT NULL,
    [EffectiveFrom] DATETIME2 (0)    NOT NULL,
    [CurrencyFrom]  CHAR (3)         NOT NULL,
    [CurrencyTo]    CHAR (3)         NOT NULL,
    [Rate]          DECIMAL (18, 10) NOT NULL,
    [IsCurrent]     BIT              CONSTRAINT [DF_CurrencyRateSource_Current] DEFAULT ((0)) NOT NULL,
    [UpdatedAt]     DATETIME2 (2)    CONSTRAINT [DF_CurrencyRateSource_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_CurrencyRateSource] PRIMARY KEY NONCLUSTERED ([id] ASC),
    CONSTRAINT [UIX_CurrencyRateSource] UNIQUE CLUSTERED ([CurrencyFrom] ASC, [CurrencyTo] ASC, [EffectiveFrom] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_CurrencyRateSource_CurrentRate]
    ON [mno].[CurrencyRateSource]([CurrencyFrom] ASC, [CurrencyTo] ASC)
    INCLUDE([Rate]) WHERE ([IsCurrent]=(1)) WITH (STATISTICS_NORECOMPUTE = ON);

