CREATE TABLE [mno].[CurrencyRate] (
    [id]            INT              IDENTITY (1, 1) NOT NULL,
    [EffectiveFrom] DATETIME2 (0)    NOT NULL,
    [CurrencyFrom]  CHAR (3)         NOT NULL,
    [CurrencyTo]    CHAR (3)         NOT NULL,
    [Rate]          DECIMAL (18, 10) NOT NULL,
    [IsCurrent]     BIT              CONSTRAINT [DF_CurrencyRate_Current] DEFAULT ((0)) NOT NULL,
    [UpdatedAt]     DATETIME2 (2)    CONSTRAINT [DF_CurrencyRate_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_CurrencyRate] PRIMARY KEY NONCLUSTERED ([id] ASC),
    CONSTRAINT [UIX_CurrencyRate] UNIQUE CLUSTERED ([CurrencyFrom] ASC, [CurrencyTo] ASC, [EffectiveFrom] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_CurrencyRate_CurrentRate]
    ON [mno].[CurrencyRate]([CurrencyFrom] ASC, [CurrencyTo] ASC)
    INCLUDE([Rate]) WHERE ([IsCurrent]=(1)) WITH (STATISTICS_NORECOMPUTE = ON);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-29
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [mno].[CurrencyRate_DataChanged]
   ON  [mno].[CurrencyRate]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'mno.CurrencyRate'

	IF NOT UPDATE(UpdatedAt)
		UPDATE c
		SET UpdatedAt = SYSUTCDATETIME()
		FROM mno.CurrencyRate c
			INNER JOIN inserted AS i ON c.id = i.id

END
