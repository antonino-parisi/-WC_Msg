CREATE TABLE [mno].[Currency] (
    [Currency]            CHAR (3)      NOT NULL,
    [CurrencyName]        VARCHAR (50)  NOT NULL,
    [Symbol]              NVARCHAR (10) NOT NULL,
    [SymbolNative]        NVARCHAR (10) NOT NULL,
    [DecimalDigits]       TINYINT       NOT NULL,
    [Rounding]            TINYINT       NOT NULL,
    [CurrencyName_plural] VARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_Currency] PRIMARY KEY CLUSTERED ([Currency] ASC)
);

