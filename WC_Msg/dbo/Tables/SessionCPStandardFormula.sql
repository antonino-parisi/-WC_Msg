CREATE TABLE [dbo].[SessionCPStandardFormula] (
    [FormulaName] NVARCHAR (250) NULL,
    [SessionId]   NVARCHAR (250) NOT NULL,
    CONSTRAINT [PK_SessionCPStandardFormula] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);

