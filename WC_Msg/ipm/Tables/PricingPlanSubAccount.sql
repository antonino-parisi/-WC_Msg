CREATE TABLE [ipm].[PricingPlanSubAccount] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [SubAccountUid] INT           NOT NULL,
    [PeriodStart]   DATE          NOT NULL,
    [PeriodEnd]     DATE          NOT NULL,
    [PricingPlanId] SMALLINT      NOT NULL,
    [CreatedAt]     DATETIME2 (2) CONSTRAINT [DF_PricingPlanSubAccount_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_PricingPlanSubAccount] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PricingPlanSubAccount_PricingPlan] FOREIGN KEY ([PricingPlanId]) REFERENCES [ipm].[PricingPlan] ([PricingPlanId]),
    CONSTRAINT [UIX_PricingPlanSubAccount_SubAccount_PeriodStart] UNIQUE NONCLUSTERED ([SubAccountUid] ASC, [PeriodStart] ASC)
);


GO


CREATE TRIGGER [ipm].[PricingPlanSubAccount_Constraints]
	ON [ipm].PricingPlanSubAccount AFTER INSERT, UPDATE
AS
BEGIN

	-- check conflict of period overlap with other records
	IF EXISTS (
		SELECT 1 
		FROM ipm.PricingPlanSubAccount v1
			INNER JOIN inserted v2 ON 
				v1.Id <> v2.Id 
				AND v2.SubAccountUid = v1.SubAccountUid
		WHERE NOT (v2.PeriodStart >= v1.PeriodEnd OR v2.PeriodEnd <= v1.PeriodStart)
	)
	BEGIN
		RAISERROR ('Time period conflicts with other existing record', 16, 1)
		ROLLBACK TRANSACTION
	END

END

GO



-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-12-28
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ipm].[PricingPlanSubAccount_DataChanged]
   ON  [ipm].PricingPlanSubAccount
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.PricingPlanSubAccount'
END
