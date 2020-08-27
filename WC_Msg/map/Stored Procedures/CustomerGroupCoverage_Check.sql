-- =============================================
-- Author: Rebecca Loh
-- Create date: 02 Mar 2020
-- Description: Checks if record exists in rt.CustomerGroupCoverage
-- Usage : EXEC map.CustomerGroupCoverage_Check @CustomerGroupId=393, @SubAccountUid=NULL, @Country='AD', @OperatorId=213003
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------

CREATE PROCEDURE map.CustomerGroupCoverage_Check
	@CustomerGroupId int,
	@SubAccountUid int = NULL,
	@Country char(2) = NULL,
	@OperatorId int = NULL,
	@TrafficCategory varchar(3) = 'DEF'
AS
BEGIN
	SELECT	CoverageId, CustomerGroupId, SubAccountUid, Country, OperatorId,
			TrafficCategory, RoutingPlanId, RoutingGroupId, PriceCurrency,
			PricingPlanId, Price, MarginRate, CompanyCurrency, CompanyPrice,
			CostCurrency, CostCalculated, CreatedBy, CreatedAt, UpdatedBy,
			UpdatedAt, PriceChangedAt, Deleted, PriceOriginalCurrency, PriceOriginal
	FROM rt.CustomerGroupCoverage
	WHERE
		CustomerGroupId = @CustomerGroupId
		AND ((@SubAccountUid IS NULL AND SubAccountUid IS NULL) OR SubAccountUid = @SubAccountUid)
		AND (@Country IS NULL OR Country = @Country)
		AND (@OperatorId IS NULL OR OperatorId = @OperatorId)
		AND (@TrafficCategory IS NULL OR TrafficCategory = @TrafficCategory) ;
END
