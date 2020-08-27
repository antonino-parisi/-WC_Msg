CREATE TABLE [dbo].[PricingFormula] (
    [ID]              INT            IDENTITY (1, 1) NOT NULL,
    [FormulaName]     NVARCHAR (250) NOT NULL,
    [CostFrom]        FLOAT (53)     NULL,
    [CostTo]          FLOAT (53)     NULL,
    [MarginPercent]   NVARCHAR (50)  NULL,
    [CreatedBy]       NVARCHAR (250) NULL,
    [LastUpdatedBy]   NVARCHAR (250) NULL,
    [DateTimeCreated] DATETIME       NULL,
    [DateTimeUpdated] DATETIME       NULL,
    [Price]           FLOAT (53)     NULL,
    [DefaultPrice]    FLOAT (53)     NULL
);

