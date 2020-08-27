CREATE TABLE [rt].[SupplierCostCoverageFuture] (
    [CostCoverageId]    INT             IDENTITY (1, 1) NOT NULL,
    [ConnUid]           INT             NOT NULL,
    [Country]           CHAR (2)        NOT NULL,
    [OperatorId]        INT             NULL,
    [SmsTypeId]         TINYINT         CONSTRAINT [DF_SupplierCostCoverageFuture_SmsTypeId] DEFAULT ((1)) NOT NULL,
    [CostLocal]         DECIMAL (12, 6) NOT NULL,
    [CostLocalCurrency] CHAR (3)        NOT NULL,
    [Active]            BIT             NOT NULL,
    [EffectiveFrom]     DATETIME2 (2)   NOT NULL,
    [CreatedAt]         DATETIME2 (2)   CONSTRAINT [DF_rtSupplierCostCoverageFuture_CreatedAt] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_rtSupplierCostCoverageFuture] PRIMARY KEY CLUSTERED ([CostCoverageId] ASC),
    CONSTRAINT [CK_SupplierCostCoverageFuture_SmsTypeId] CHECK ([SmsTypeId]=(1) OR [SmsTypeId]=(0)),
    CONSTRAINT [UIX_rtSupplierCostCoverageFuture] UNIQUE NONCLUSTERED ([EffectiveFrom] ASC, [ConnUid] ASC, [Country] ASC, [OperatorId] ASC, [SmsTypeId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 - MO, 1 - MT', @level0type = N'SCHEMA', @level0name = N'rt', @level1type = N'TABLE', @level1name = N'SupplierCostCoverageFuture', @level2type = N'COLUMN', @level2name = N'SmsTypeId';

