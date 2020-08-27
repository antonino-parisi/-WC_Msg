CREATE TABLE [rt].[SupplierCostCoverageHistory] (
    [Id]                INT             IDENTITY (1, 1) NOT NULL,
    [ChangedBy]         NVARCHAR (128)  NOT NULL,
    [ChangedAt]         DATETIME2 (7)   NOT NULL,
    [Action]            VARCHAR (50)    NOT NULL,
    [CostCoverageId]    INT             NOT NULL,
    [RouteUid]          INT             NOT NULL,
    [Country]           CHAR (2)        NOT NULL,
    [OperatorId]        INT             NULL,
    [CostLocal]         DECIMAL (12, 6) NOT NULL,
    [CostLocalCurrency] CHAR (3)        NOT NULL,
    [CostEUR]           DECIMAL (12, 6) NOT NULL,
    [EffectiveFrom]     DATETIME2 (7)   NOT NULL,
    [CreatedAt]         DATETIME2 (7)   NOT NULL,
    [UpdatedAt]         DATETIME2 (7)   NOT NULL,
    [SmsTypeId]         TINYINT         NOT NULL,
    [Deleted]           BIT             NULL,
    CONSTRAINT [PK_rtSupplierCostCoverageHistory] PRIMARY KEY CLUSTERED ([Id] ASC)
);

