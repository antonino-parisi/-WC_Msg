CREATE TABLE [rt].[SupplierCostCoverageSID] (
    [CostCoverageSIDId] INT             IDENTITY (1, 1) NOT NULL,
    [ConnUid]           INT             NOT NULL,
    [Country]           CHAR (2)        NOT NULL,
    [OperatorId]        INT             NULL,
    [BillingStart]      SMALLDATETIME   NOT NULL,
    [BillingEnd]        SMALLDATETIME   NOT NULL,
    [SID]               VARCHAR (22)    NOT NULL,
    [Currency]          CHAR (3)        NOT NULL,
    [CostPerSms]        DECIMAL (19, 7) NOT NULL,
    [CreatedAt]         DATETIME2 (2)   CONSTRAINT [DF_rtSupplierCostCoverageSID_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]         DATETIME2 (2)   CONSTRAINT [DF_rtSupplierCostCoverageSID_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_rtSupplierCostCoverageSID] PRIMARY KEY CLUSTERED ([CostCoverageSIDId] ASC),
    CONSTRAINT [CK_SupplierCostCoverageSID_BillingEnd] CHECK ([BillingEnd]>[BillingStart]),
    CONSTRAINT [FK_SupplierCostCoverageSID_SupplierCostCoverageSID] FOREIGN KEY ([CostCoverageSIDId]) REFERENCES [rt].[SupplierCostCoverageSID] ([CostCoverageSIDId]),
    CONSTRAINT [UIX_rtSupplierCostCoverageSID] UNIQUE NONCLUSTERED ([ConnUid] ASC, [Country] ASC, [OperatorId] ASC, [SID] ASC)
);


GO

CREATE TRIGGER [rt].[SupplierCostCoverageSID_Constraints]
	ON [rt].[SupplierCostCoverageSID] AFTER INSERT, UPDATE
AS
BEGIN

	-- check conflict of period overlap with other records
	IF EXISTS (
		SELECT 1 
		FROM rt.SupplierCostCoverageSID v1
			INNER JOIN inserted v2 ON 
				v1.CostCoverageSIDId <> v2.CostCoverageSIDId 
				AND v2.ConnUid = v1.ConnUid
				AND v2.Country = v1.Country
				AND ISNULL(v2.OperatorId, 0) = ISNULL(v1.OperatorId, 0)
				AND v2.SID = v1.SID
		WHERE NOT (v2.BillingStart >= v1.BillingEnd OR v2.BillingEnd <= v1.BillingStart)
	)
	BEGIN
		RAISERROR ('Time period conflicts with other existing record', 16, 1)
		ROLLBACK TRANSACTION
	END

END

GO

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER [rt].[SupplierCostCoverageSID_DataChanged] 
   ON  rt.SupplierCostCoverageSID 
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	SET NOCOUNT ON

	IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN

	IF NOT UPDATE(UpdatedAt)
		UPDATE f
		SET UpdatedAt = SYSUTCDATETIME()
		FROM rt.SupplierCostCoverageSID f
			INNER JOIN inserted AS i ON f.CostCoverageSIDId = i.CostCoverageSIDId

	EXEC ms.DbDependency_DataChanged @Key = 'rt.SupplierCostCoverageSID'
END
