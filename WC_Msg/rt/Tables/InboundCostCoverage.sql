CREATE TABLE [rt].[InboundCostCoverage] (
    [CostCoverageId]     INT             IDENTITY (1, 1) NOT NULL,
    [ConnUid]            INT             NOT NULL,
    [VNType]             CHAR (1)        NOT NULL,
    [VNCountry]          CHAR (2)        NOT NULL,
    [MSISDNCountry]      CHAR (2)        NULL,
    [MSISDNOperatorId]   INT             NULL,
    [BillingStart]       SMALLDATETIME   CONSTRAINT [DF_SupplierCostCoverageInbound_PeriodStart] DEFAULT (sysutcdatetime()) NOT NULL,
    [BillingEnd]         SMALLDATETIME   NOT NULL,
    [Currency]           CHAR (3)        NOT NULL,
    [CostPerSmsSupplier] DECIMAL (18, 6) NOT NULL,
    [CostPerSmsOperator] DECIMAL (18, 6) CONSTRAINT [DF_SupplierCostCoverageInbound_CostPerSmsOperator] DEFAULT ((0)) NOT NULL,
    [CostPerSms]         AS              ([CostPerSmsSupplier]+[CostPerSmsOperator]),
    [UpdatedAt]          DATETIME2 (2)   CONSTRAINT [DF_SupplierCostCoverageInbound_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_InboundCostCoverage] PRIMARY KEY CLUSTERED ([CostCoverageId] ASC),
    CONSTRAINT [CK_InboundCostCoverage_BillingEnd] CHECK ([BillingEnd]>[BillingStart]),
    CONSTRAINT [FK_InboundCostCoverage_Currency] FOREIGN KEY ([Currency]) REFERENCES [mno].[Currency] ([Currency]),
    CONSTRAINT [FK_InboundCostCoverage_DimVirtualNumberType] FOREIGN KEY ([VNType]) REFERENCES [ms].[DimVirtualNumberType] ([VNType]),
    CONSTRAINT [FK_InboundCostCoverage_MSISDNCountry] FOREIGN KEY ([MSISDNCountry]) REFERENCES [mno].[Country] ([CountryISO2alpha]),
    CONSTRAINT [FK_InboundCostCoverage_MSISDNOperator] FOREIGN KEY ([MSISDNOperatorId]) REFERENCES [mno].[Operator] ([OperatorId]),
    CONSTRAINT [FK_InboundCostCoverage_VNCountry] FOREIGN KEY ([VNCountry]) REFERENCES [mno].[Country] ([CountryISO2alpha]),
    CONSTRAINT [UIX_InboundCostCoverage] UNIQUE NONCLUSTERED ([ConnUid] ASC, [VNType] ASC, [VNCountry] ASC, [MSISDNCountry] ASC, [MSISDNOperatorId] ASC, [BillingStart] ASC)
);


GO

-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2020-03-06
-- =============================================
CREATE TRIGGER rt.InboundCostCoverage_DataChanged 
   ON  rt.InboundCostCoverage 
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN

	UPDATE f
	SET UpdatedAt = SYSUTCDATETIME()
	FROM rt.InboundCostCoverage f
		INNER JOIN inserted AS i ON f.CostCoverageId = i.CostCoverageId

	EXEC ms.DbDependency_DataChanged @Key = 'rt.InboundCostCoverage'
END

GO


CREATE TRIGGER [rt].[InboundCostCoverage_Constraints]
	ON [rt].[InboundCostCoverage] AFTER INSERT, UPDATE
AS
BEGIN

	-- check conflict of period overlap with other records
	IF EXISTS (
		SELECT 1 
		FROM rt.InboundCostCoverage v1
			INNER JOIN inserted v2 ON 
				v1.CostCoverageId <> v2.CostCoverageId 
				AND v2.ConnUid = v1.ConnUid
				AND v2.VNType = v1.VNType
				AND v2.VNCountry = v1.VNCountry
				AND ISNULL(v2.MSISDNCountry, '') = ISNULL(v1.MSISDNCountry, '')
				AND ISNULL(v2.MSISDNOperatorId, 0) = ISNULL(v1.MSISDNOperatorId, 0)
		WHERE NOT (v2.BillingStart >= v1.BillingEnd OR v2.BillingEnd <= v1.BillingStart)
	)
	BEGIN
		RAISERROR ('Time period conflicts with other existing record', 16, 1)
		ROLLBACK TRANSACTION
	END

END
