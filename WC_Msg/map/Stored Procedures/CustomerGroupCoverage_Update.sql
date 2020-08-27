
CREATE PROCEDURE [map].[CustomerGroupCoverage_Update]
	@CoverageId int,		--filter
	--@CustomerGroupId int,	--filter
	--@SubAccountUid int,		--filter
	--@Country char(2),		--filter
	--@OperatorId int,		--filter
	--@TrafficCategory varchar(3) = 'DEF',	--filter
	@RoutingPlanId int = NULL,		-- new value. Must be NULL if @RoutingGroupId IS NOT NULL
	@RoutingGroupId int = NULL,		-- new value. Must be NULL if @RoutingPlanId IS NOT NULL
	@PricingPlanId int = NULL,		-- new value. Must be NULL if @Price or @MarginRate IS NOT NULL
	@PriceCurrency char(3) = 'EUR',
	@Price decimal(12,6) = NULL,
	@MarginRate decimal(8,4) = NULL,
	@PriceContractCurrency char(3) = NULL,	-- TODO, not used yet
	@PriceContract decimal(12,6) = NULL,	-- TODO, not used yet
	@UpdatedBy smallint
AS
BEGIN

	-- Routing validation
	IF  (@RoutingPlanId IS NULL AND @RoutingGroupId IS NULL) OR
		(@RoutingPlanId IS NOT NULL AND @RoutingGroupId IS NOT NULL)
	BEGIN
		THROW 51000, 'Rejected input values combination: @RoutingPlanId vs @RoutingGroupId', 1;
	END

	-- Pricing validation
	IF  (@PricingPlanId IS NULL AND @Price IS NULL AND @MarginRate IS NULL) OR
		(@PricingPlanId IS NOT NULL AND @Price IS NOT NULL AND @MarginRate IS NOT NULL)
	BEGIN
		THROW 51001, 'Rejected input values combination: @PricingPlanId vs @Price vs @MarginRate', 1;
	END

	DECLARE @Country char(2)
	DECLARE @OperatorId int
	DECLARE @TrafficCategory varchar(3)
	DECLARE @CostCurrency char(3) = 'EUR'
	DECLARE @CostCalculated decimal(12,6)
	DECLARE @SubAccountUid int
	--DECLARE @Output TABLE (CoverageId int)

	SELECT @Country = Country, @OperatorId = OperatorId, @TrafficCategory = TrafficCategory, @SubAccountUid = SubAccountUid
	FROM rt.CustomerGroupCoverage 
	WHERE CoverageId = @CoverageId

	-- Fill @RoutingGroupId if it's not custom and based on @RoutingPlanId
	IF @RoutingPlanId IS NOT NULL
	BEGIN
		SELECT @RoutingGroupId = RoutingGroupId, @CostCalculated = CostCalculated, @CostCurrency = CostCurrency
		FROM rt.RoutingPlanCoverage
		WHERE RoutingPlanId = @RoutingPlanId AND Deleted = 0
			AND Country = @Country AND ISNULL(OperatorId, 0) = ISNULL(@OperatorId, 0)
			AND TrafficCategory = ISNULL(@TrafficCategory, 'DEF')
	END

	-- Fill @Price if it's not custom and based on @PricingPlanId
	IF @PricingPlanId IS NOT NULL
	BEGIN
		SELECT @Price = Price, @MarginRate = MarginRate, @PriceCurrency = Currency
		FROM rt.PricingPlanCoverage
		WHERE PricingPlanId = @PricingPlanId AND Deleted = 0
			AND Country = @Country AND ISNULL(OperatorId, 0) = ISNULL(@OperatorId, 0)
	END

	-- TODO: If @RoutingPlanId IS NULL -> @CostCalculated will be null -> @Price based on @MarginRate will be null

	-- Calc @Price if not provided. WARNING: not all combinations covered here. @Price still might be NULL. Needs futher improvement.
	IF @Price IS NULL
	BEGIN
		SET @Price = (@CostCalculated * 100) / (100 - @MarginRate)
	END

	-- We update exception rules first (for code simplicity) if change is in default group plan
	IF @SubAccountUid IS NULL
	BEGIN
		UPDATE c
		SET 
			RoutingPlanId	= @RoutingPlanId,
			RoutingGroupId	= @RoutingGroupId,
			--PriceCurrency	= @PriceCurrency, 
			CompanyCurrency = @CostCurrency, 
			Price			= IIF(c.MarginRate IS NULL, c.Price, (@CostCalculated * 100) / (100 - c.MarginRate)), 
			CompanyPrice	= IIF(c.MarginRate IS NULL, c.CompanyPrice, (@CostCalculated * 100) / (100 - c.MarginRate)), 
			CostCurrency	= @CostCurrency, 
			CostCalculated  = @CostCalculated,
			UpdatedAt = SYSUTCDATETIME(), 
			UpdatedBy = @UpdatedBy
		FROM rt.CustomerGroupCoverage d
			INNER JOIN rt.CustomerGroupCoverage c ON
				d.CustomerGroupId = c.CustomerGroupId
				AND d.Country = c.Country
				AND ISNULL(d.OperatorId, 0) = ISNULL(c.OperatorId, 0)
				AND d.TrafficCategory = c.TrafficCategory
				AND d.RoutingPlanId = c.RoutingPlanId -- if same Routing Plan only!
				AND d.PriceCurrency = c.PriceCurrency AND d.PriceCurrency = d.CostCurrency
		WHERE d.CoverageId = @CoverageId AND d.SubAccountUid IS NULL AND c.SubAccountUid IS NOT NULL
			AND d.RoutingGroupId <> @RoutingGroupId -- if only RoutingPlanId/RoutingGroupId is going to be changed
			
	END

	-- Main update of prepared data
	UPDATE rt.CustomerGroupCoverage 
	SET 
		RoutingPlanId = @RoutingPlanId,
		RoutingGroupId = @RoutingGroupId, 
		PricingPlanId = @PricingPlanId, 
		PriceCurrency = 'EUR',
		Price = mno.CurrencyConverter(@Price, @PriceCurrency, 'EUR', DEFAULT),
		PriceOriginalCurrency = @PriceCurrency, 
		PriceOriginal = @Price, 
		MarginRate = @MarginRate, 
		CompanyCurrency = @CostCurrency, 
		CompanyPrice = @Price,
		CostCurrency = @CostCurrency, 
		CostCalculated  = @CostCalculated, 
		UpdatedAt = SYSUTCDATETIME(), 
		UpdatedBy = @UpdatedBy
	--OUTPUT inserted.CoverageId INTO @Output (CoverageId)
	WHERE CoverageId = @CoverageId

END
