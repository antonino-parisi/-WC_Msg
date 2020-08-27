CREATE TABLE [rt].[SupplierCostCoverageSIDGroup] (
    [CostCoverageSIDId] INT           NOT NULL,
    [SID]               VARCHAR (22)  NOT NULL,
    [CreatedAt]         DATETIME2 (2) CONSTRAINT [DF_rtSupplierCostCoverageSIDGroup_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]         DATETIME2 (2) CONSTRAINT [DF_rtSupplierCostCoverageSIDGroup_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_SupplierCostCoverageSIDGroup] PRIMARY KEY CLUSTERED ([CostCoverageSIDId] ASC, [SID] ASC),
    CONSTRAINT [FK_SupplierCostCoverageSIDGroup_SupplierCostCoverageSID] FOREIGN KEY ([CostCoverageSIDId]) REFERENCES [rt].[SupplierCostCoverageSID] ([CostCoverageSIDId])
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER [rt].[SupplierCostCoverageSIDGroup_DataChanged] 
   ON  rt.SupplierCostCoverageSIDGroup 
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	SET NOCOUNT ON

	IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN

	IF NOT UPDATE(UpdatedAt)
		UPDATE f
		SET UpdatedAt = SYSUTCDATETIME()
		FROM rt.SupplierCostCoverageSIDGroup f
			INNER JOIN inserted AS i ON f.CostCoverageSIDId = i.CostCoverageSIDId AND f.SID = i.SID

	EXEC ms.DbDependency_DataChanged @Key = 'rt.SupplierCostCoverageSID'
END
