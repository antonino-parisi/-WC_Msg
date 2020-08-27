CREATE TABLE [rt].[PricingPlanCoverage] (
    [PricingPlanCoverageId] INT             IDENTITY (1, 1) NOT NULL,
    [PricingPlanId]         INT             NOT NULL,
    [Country]               CHAR (2)        NOT NULL,
    [OperatorId]            INT             NULL,
    [Currency]              CHAR (3)        NOT NULL,
    [PricingFormulaId]      INT             NULL,
    [Price]                 DECIMAL (12, 6) NULL,
    [MarginRate]            DECIMAL (8, 4)  NULL,
    [CreatedAt]             DATETIME2 (2)   CONSTRAINT [DF_PricingPlanCoverage_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [CreatedBy]             SMALLINT        NULL,
    [UpdatedAt]             DATETIME2 (2)   CONSTRAINT [DF_PricingPlanCoverage_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedBy]             SMALLINT        NULL,
    [Deleted]               BIT             CONSTRAINT [DF_PricingPlanCoverage_Deleted] DEFAULT ((0)) NOT NULL,
    [CompanyCurrency]       CHAR (3)        NULL,
    [CompanyPrice]          DECIMAL (12, 6) NULL,
    CONSTRAINT [PK_PricingPlanCoverage] PRIMARY KEY CLUSTERED ([PricingPlanCoverageId] ASC),
    CONSTRAINT [CK_PricingPlanCoverage_Price_Margin] CHECK ([Price] IS NOT NULL OR [MarginRate] IS NOT NULL),
    CONSTRAINT [FK_PricingPlanCoverage_PricingPlan] FOREIGN KEY ([PricingPlanId]) REFERENCES [rt].[PricingPlan] ([PricingPlanId]),
    CONSTRAINT [UIX_PricingPlanCoverage_Key] UNIQUE NONCLUSTERED ([PricingPlanId] ASC, [Country] ASC, [OperatorId] ASC)
);


GO

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 24 Sep 2019 Rebecca	Modify for local currency
-- =============================================

CREATE TRIGGER [rt].[PricingPlanCoverage_DataChanged] 
   ON  [rt].[PricingPlanCoverage] 
   AFTER INSERT, UPDATE
AS 
BEGIN
	UPDATE f
	SET [UpdatedAt] = SYSUTCDATETIME()
	FROM [rt].[PricingPlanCoverage] f
		INNER JOIN inserted AS i ON f.PricingPlanCoverageId = i.PricingPlanCoverageId

	---- update dependencies
	---- Looping through table records where looping column has duplicate values
	--DECLARE @LoopCounter INT, @MaxCounter INT
	--SELECT @LoopCounter = MIN(PricingPlanCoverageId), @MaxCounter = MAX(PricingPlanCoverageId) FROM inserted
	--WHILE (@LoopCounter IS NOT NULL AND  @LoopCounter <= @MaxCounter)
	--BEGIN
	--	-- update dependencies
	--	EXEC rt.PricingPlanCoverage_UpdateDependencies @LoopCounter
	--	PRINT dbo.Log_ROWCOUNT ('Update Dependencies of PricingPlanCoverageId=' + cast(@LoopCounter as varchar(10)))

	--	SELECT @LoopCounter = MIN(PricingPlanCoverageId) 
	--	FROM inserted WHERE PricingPlanCoverageId > @LoopCounter
	--END

	DECLARE @Tab TABLE (CoverageId int, PriceCurrency char(3), Price decimal(12,6), MarginRate decimal(8,4), UpdatedBy smallint, PriceEUR decimal(12,6)) ;

	INSERT INTO @Tab
	SELECT CoverageId, Currency, Price, MarginRate, UpdatedBy,
			mno.CurrencyConverter(Price, Currency, 'EUR', DEFAULT) PriceEUR
	FROM
		(SELECT cgc.CoverageId, ppc.Currency, 
				IIF (ppc.MarginRate IS NULL, ppc.Price, (rt.CostCalculated * 100) / (100 - ppc.MarginRate)) Price,
				ppc.MarginRate, ppc.UpdatedBy
		--SELECT @Price = IIF (ppc.MarginRate IS NULL, ppc.Price, (rt.CostCalculated * 100) / (100 - ppc.MarginRate)),
		--		@PriceCurrency = ppc.Currency
		FROM inserted ppc
			INNER JOIN rt.CustomerGroupCoverage cgc 
				ON cgc.PricingPlanId = ppc.PricingPlanId
					AND cgc.Country = ppc.Country 
					AND ISNULL(cgc.OperatorId, 0) = ISNULL(ppc.OperatorId, 0)
			LEFT JOIN rt.RoutingGroup rg ON rg.RoutingGroupId = cgc.RoutingGroupId
			LEFT JOIN rt.RoutingTier rt ON rt.TierLevel = 1 AND rt.RoutingGroupId = rg.RoutingGroupId
		WHERE ppc.Deleted = 0
		) t ;

	-- update price in CustomerGroup coverages
/*
	UPDATE cgc
	SET MarginRate = ppc.MarginRate, 
		PriceCurrency = 'EUR',
		Price = mno.CurrencyConverter(@Price, ppc.Currency, 'EUR', DEFAULT),
		CompanyPrice = mno.CurrencyConverter(@Price, ppc.Currency, 'EUR', DEFAULT),
		PriceOriginalCurrency = @PriceCurrency,
		PriceOriginal = @Price,
		UpdatedBy = ppc.UpdatedBy
		--recalc Price if it's margin-based
		--Price = IIF (ppc.MarginRate IS NULL, ppc.Price, (rt.CostCalculated * 100) / (100 - ppc.MarginRate)),
		--CompanyPrice = IIF (ppc.MarginRate IS NULL, ppc.Price, (rt.CostCalculated * 100) / (100 - ppc.MarginRate))
	FROM inserted ppc
		INNER JOIN rt.CustomerGroupCoverage cgc 
			ON cgc.PricingPlanId = ppc.PricingPlanId
				AND cgc.Country = ppc.Country 
				AND ISNULL(cgc.OperatorId, 0) = ISNULL(ppc.OperatorId, 0)
		LEFT JOIN rt.RoutingGroup rg ON rg.RoutingGroupId = cgc.RoutingGroupId
		LEFT JOIN rt.RoutingTier rt ON rt.TierLevel = 1 AND rt.RoutingGroupId = rg.RoutingGroupId
	WHERE ppc.Deleted = 0 ;
*/
	UPDATE cgc
	SET MarginRate = t.MarginRate, 
		PriceCurrency = 'EUR',
		Price = t.PriceEUR,
		CompanyPrice = t.PriceEUR,
		PriceOriginalCurrency = t.PriceCurrency,
		PriceOriginal = t.Price,
		UpdatedBy = t.UpdatedBy
	FROM rt.CustomerGroupCoverage cgc WITH (NOLOCK)
		INNER JOIN @Tab t
			ON cgc.CoverageId = t.CoverageId ;
END
