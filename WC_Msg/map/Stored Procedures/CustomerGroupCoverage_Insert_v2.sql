
CREATE PROCEDURE [map].[CustomerGroupCoverage_Insert_v2]
	@CustomerGroupId int,	--filter, can't be NULL
	@SubAccountUid int,		--filter, can be NULL
	@Country char(2),		--filter
	@OperatorId int,		--filter
	@TrafficCategory varchar(3) = 'DEF',	--filter
	@RoutingPlanId int = NULL,		-- new value. Must be NULL if @RoutingGroupId IS NOT NULL
	@RoutingGroupId int = NULL,		-- new value. Must be NULL if @RoutingPlanId IS NOT NULL
	@PricingPlanId int = NULL,		-- new value. Must be NULL if @Price or @MarginRate IS NOT NULL
	@PriceCurrency char(3) = 'EUR',
	@Price decimal(12,6) = NULL,	-- new value. Must be NULL if @PricingPlanId or @MarginRate IS NOT NULL
	@MarginRate decimal(8,4) = NULL,	-- new value. Must be NULL if @Price or @MarginRate IS NOT NULL
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

	IF  (@CustomerGroupId IS NOT NULL AND (
			(@RoutingPlanId IS NULL AND @RoutingGroupId IS NULL) OR
			(@PricingPlanId IS NULL AND @Price IS NULL AND @MarginRate IS NULL)
		))
	BEGIN
		THROW 51001, 'Rejected input values combination: Routing AND Pricing must be set for @CustomerGroupId', 1;
	END

	DECLARE @CostCurrency char(3) = 'EUR'
	DECLARE @CostCalculated decimal(12,6)
	DECLARE @Output TABLE (CoverageId int)

	-- Fill @CustomerGroupId by SubAccount from group members list if it's not set
	IF @CustomerGroupId IS NULL
	BEGIN
		SELECT @CustomerGroupId = CustomerGroupId
		FROM rt.CustomerGroupCoverage
		WHERE SubAccountUid = @SubAccountUid
	END

	-- Fill @RoutingGroupId if it's not custom and based on @RoutingPlanId
	IF @RoutingPlanId IS NOT NULL
	BEGIN
		SELECT @RoutingGroupId = RoutingGroupId, @CostCalculated = CostCalculated, @CostCurrency = CostCurrency
		FROM rt.RoutingPlanCoverage
		WHERE RoutingPlanId = @RoutingPlanId AND Deleted = 0
			AND Country = @Country AND ISNULL(OperatorId, 0) = ISNULL(@OperatorId, 0)
			AND TrafficCategory = ISNULL(@TrafficCategory, 'DEF')
	END

	-- Fill @PricingPlanId if it's not custom and based on @RoutingPlanId
	IF @PricingPlanId IS NOT NULL
	BEGIN
		SELECT @Price = Price, @MarginRate = MarginRate, @PriceCurrency = Currency
		FROM rt.PricingPlanCoverage
		WHERE PricingPlanId = @PricingPlanId AND Deleted = 0
			AND Country = @Country AND ISNULL(OperatorId, 0) = ISNULL(@OperatorId, 0)
	END

	-- Calc @Price if not provided. WARNING: not all combinations covered here. @Price still might be NULL. Needs futher improvement.
	IF @Price IS NULL
	BEGIN
		SET @Price = (@CostCalculated * 100) / (100 - @MarginRate) ;
		SET @PriceCurrency = @CostCurrency ;
	END

	-- Hard delete of prev record
	DELETE TOP (1) FROM rt.CustomerGroupCoverage
	WHERE Deleted = 1 AND 
		ISNULL(CustomerGroupId, 0) = ISNULL(@CustomerGroupId, 0) AND
		ISNULL(SubAccountUid, 0) = ISNULL(@SubAccountUid, 0) AND
		Country = @Country AND
		ISNULL(OperatorId, 0) = ISNULL(@OperatorId, 0) AND
		TrafficCategory = @TrafficCategory

	-- Main insert of prepared data
	INSERT INTO rt.CustomerGroupCoverage (
		CustomerGroupId, SubAccountUid, Country, OperatorId, TrafficCategory, 
		RoutingPlanId, RoutingGroupId, 
		PricingPlanId, PriceCurrency, Price, MarginRate, 
		PriceOriginalCurrency, PriceOriginal,
		CompanyCurrency, CompanyPrice,
		CostCurrency, CostCalculated, 
		CreatedAt, CreatedBy, UpdatedAt, UpdatedBy)
	OUTPUT inserted.CoverageId INTO @Output (CoverageId)
	VALUES (@CustomerGroupId, @SubAccountUid, @Country, @OperatorId, @TrafficCategory, 
		@RoutingPlanId, @RoutingGroupId, @PricingPlanId,
		'EUR', mno.CurrencyConverter(@Price, @PriceCurrency, 'EUR', DEFAULT), @MarginRate,
		@PriceCurrency, @Price,
		@PriceCurrency, @Price,
		@CostCurrency, @CostCalculated, 
		SYSUTCDATETIME(), @UpdatedBy, SYSUTCDATETIME(), @UpdatedBy)

	SELECT CoverageId FROM @Output
END
