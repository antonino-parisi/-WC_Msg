CREATE TABLE [ipm].[PricingPlanCoverage] (
    [CoverageId]      INT             IDENTITY (1, 1) NOT NULL,
    [PricingPlanId]   SMALLINT        NOT NULL,
    [ChannelTypeId]   TINYINT         NOT NULL,
    [ContentTypeCode] VARCHAR (10)    NOT NULL,
    [Country]         CHAR (2)        NULL,
    [PeriodStart]     DATE            NOT NULL,
    [PeriodEnd]       DATE            NOT NULL,
    [Currency]        CHAR (3)        NOT NULL,
    [Price]           DECIMAL (18, 6) NOT NULL,
    [CreatedAt]       DATETIME2 (2)   CONSTRAINT [DF_PricingPlanCoverage_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_PricingPlanCoverage] PRIMARY KEY CLUSTERED ([CoverageId] ASC),
    CONSTRAINT [CK_PricingPlanCoverage_PeriodEnd] CHECK ([PeriodEnd]>[PeriodStart]),
    CONSTRAINT [FK_PricingPlanCoverage_ChannelType] FOREIGN KEY ([ChannelTypeId]) REFERENCES [ipm].[ChannelType] ([ChannelTypeId]),
    CONSTRAINT [FK_PricingPlanCoverage_PricingPlan] FOREIGN KEY ([PricingPlanId]) REFERENCES [ipm].[PricingPlan] ([PricingPlanId]),
    CONSTRAINT [UIX_PricingPlanCoverage] UNIQUE NONCLUSTERED ([PricingPlanId] ASC, [ChannelTypeId] ASC, [ContentTypeCode] ASC, [Country] ASC, [PeriodStart] ASC)
);


GO

CREATE TRIGGER ipm.PricingPlanCoverage_Constraints
	ON ipm.PricingPlanCoverage AFTER INSERT, UPDATE
AS
BEGIN

	
	-- check conflict of period overlap with other records
	IF EXISTS (
		SELECT 1 
		FROM ipm.PricingPlanCoverage v1
			INNER JOIN inserted v2 ON 
				v1.CoverageId <> v2.CoverageId 
				AND v2.PricingPlanId = v1.PricingPlanId
				AND v2.ChannelTypeId = v1.ChannelTypeId
				AND v2.ContentTypeCode = v1.ContentTypeCode
				AND v2.Country = v1.Country
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
CREATE TRIGGER [ipm].[PricingPlanCoverage_DataChanged]
   ON  [ipm].PricingPlanCoverage
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.PricingPlanCoverage'
END
