CREATE TABLE [rt].[PricingPlan] (
    [PricingPlanId]   INT             IDENTITY (1, 1) NOT NULL,
    [PricingPlanName] NVARCHAR (100)  NOT NULL,
    [Description]     NVARCHAR (1000) NULL,
    [OwnerId]         SMALLINT        NULL,
    [CreatedAt]       DATETIME2 (2)   CONSTRAINT [DF_PricingPlan_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]       DATETIME2 (2)   CONSTRAINT [DF_PricingPlan_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Deleted]         BIT             CONSTRAINT [DF_PricingPlan_Deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PricingPlan] PRIMARY KEY CLUSTERED ([PricingPlanId] ASC),
    CONSTRAINT [UIX_PricingPlan_Name] UNIQUE NONCLUSTERED ([PricingPlanName] ASC)
);


GO


-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER [rt].[PricingPlan_DataChanged] 
   ON  [rt].[PricingPlan] 
   AFTER UPDATE
AS 
BEGIN

	IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN

	UPDATE f
	SET [UpdatedAt] = SYSUTCDATETIME()
	FROM [rt].[PricingPlan] f
		INNER JOIN inserted AS i ON f.PricingPlanId = i.PricingPlanId
END
