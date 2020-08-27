CREATE TABLE [rt].[CustomerGroupCoverage] (
    [CoverageId]            INT             IDENTITY (1, 1) NOT NULL,
    [CustomerGroupId]       INT             NOT NULL,
    [SubAccountUid]         INT             NULL,
    [Country]               CHAR (2)        NOT NULL,
    [OperatorId]            INT             NULL,
    [TrafficCategory]       VARCHAR (3)     CONSTRAINT [DF_CustomerGroupCoverage_TrafficCategory] DEFAULT ('DEF') NOT NULL,
    [RoutingPlanId]         INT             NULL,
    [RoutingGroupId]        INT             NOT NULL,
    [PriceCurrency]         CHAR (3)        NOT NULL,
    [PricingPlanId]         INT             NULL,
    [Price]                 DECIMAL (12, 6) NULL,
    [MarginRate]            DECIMAL (8, 4)  NULL,
    [CompanyCurrency]       CHAR (3)        NOT NULL,
    [CompanyPrice]          DECIMAL (12, 6) NULL,
    [CostCurrency]          CHAR (3)        NULL,
    [CostCalculated]        DECIMAL (12, 6) NULL,
    [CreatedBy]             SMALLINT        NULL,
    [CreatedAt]             DATETIME2 (2)   CONSTRAINT [DF_CustomerGroupCoverage_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedBy]             SMALLINT        NULL,
    [UpdatedAt]             DATETIME2 (2)   CONSTRAINT [DF_CustomerGroupCoverage_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [PriceChangedAt]        DATETIME2 (2)   CONSTRAINT [DF_CustomerGroupCoverage_PriceChangedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Deleted]               BIT             CONSTRAINT [DF_CustomerGroupCoverage_Deleted] DEFAULT ((0)) NOT NULL,
    [PriceOriginalCurrency] CHAR (3)        NULL,
    [PriceOriginal]         DECIMAL (12, 6) NULL,
    CONSTRAINT [PK_CustomerGroupCoverage] PRIMARY KEY CLUSTERED ([CoverageId] ASC),
    CONSTRAINT [CK_CustomerGroupCoverage_CostCurrency] CHECK ([CostCurrency]='EUR'),
    CONSTRAINT [CK_CustomerGroupCoverage_PriceCurrency] CHECK ([PriceCurrency]='EUR'),
    CONSTRAINT [FK_CustomerGroupCoverage_RoutingGroup] FOREIGN KEY ([RoutingGroupId]) REFERENCES [rt].[RoutingGroup] ([RoutingGroupId]),
    CONSTRAINT [UIX_CustomerGroupCoverage_Key] UNIQUE NONCLUSTERED ([CustomerGroupId] ASC, [SubAccountUid] ASC, [Country] ASC, [OperatorId] ASC, [TrafficCategory] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER [rt].[CustomerGroupCoverage_DataChanged] 
   ON  [rt].[CustomerGroupCoverage] AFTER UPDATE
AS 
BEGIN

	-- update price in EUR
	IF UPDATE(PriceOriginal)
	BEGIN
		UPDATE f
		SET 
			Price			= mno.CurrencyConverter(i.PriceOriginal, i.PriceOriginalCurrency, i.PriceCurrency, DEFAULT),
			CompanyPrice	= mno.CurrencyConverter(i.PriceOriginal, i.PriceOriginalCurrency, i.PriceCurrency, DEFAULT)
		FROM rt.CustomerGroupCoverage f
			INNER JOIN inserted AS i ON f.CoverageId = i.CoverageId
	END
	
	-- track if Price changed, used in process of customer notification on price change
	UPDATE f
	SET UpdatedAt = SYSUTCDATETIME(), 
		PriceChangedAt = IIF(i.Price <> d.Price OR i.PriceCurrency <> d.PriceCurrency OR 
							i.PriceOriginal <> d.PriceOriginal OR i.PriceOriginalCurrency <> d.PriceOriginalCurrency, 
							SYSUTCDATETIME(), d.PriceChangedAt)
	FROM rt.CustomerGroupCoverage f
		INNER JOIN inserted AS i ON f.CoverageId = i.CoverageId
		INNER JOIN deleted AS d ON f.CoverageId = d.CoverageId

END
