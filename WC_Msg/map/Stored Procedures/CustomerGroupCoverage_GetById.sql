-- exec [map].[CustomerGroupCoverage_GetById] @CustomerGroupId = 235
CREATE PROCEDURE [map].[CustomerGroupCoverage_GetById]
	@CustomerGroupId int,		--filter
	@SubAccountUid int = NULL,	--filter, NULL means to get data of default coverage
	@OutputTiers bit = 0
AS
BEGIN

	-- Main select
	SELECT
		cgc.CoverageId,
		cgc.CustomerGroupId, 
		cgc.SubAccountUid, 
		cgc.Country, c.CountryName, 
		cgc.OperatorId, o.OperatorName, o.MCC_List AS MCC, o.MNC_List AS MNCs,
		cgc.TrafficCategory, 
		cgc.RoutingPlanId, rp.RoutingPlanName, cgc.RoutingGroupId,
		rg.TierLevelCurrent, rtL1.ConnSummary AS L1_ConnSummary,
		cgc.PricingPlanId, pp.PricingPlanName,
		ISNULL(cgc.PriceOriginalCurrency, PriceCurrency) PriceCurrency, 
		IIF(cgc.MarginRate IS NOT NULL, 'M', 'F') AS PricingMethod,
		IIF(cgc.MarginRate IS NOT NULL, CAST(mno.CurrencyConverter((cgc.CostCalculated * 100) / (100 - cgc.MarginRate), cgc.CostCurrency, ISNULL(cgc.PriceOriginalCurrency, PriceCurrency), DEFAULT) as decimal(12,6)), ISNULL(cgc.PriceOriginal, Price)) AS Price, 
		cgc.MarginRate,
		cgc.CompanyCurrency, cgc.CompanyPrice,
		cgc.CostCurrency, cgc.CostCalculated,
		cgc.CreatedAt, cgc.CreatedBy, cgc.UpdatedAt, cgc.UpdatedBy
	--SELECT *
	FROM rt.CustomerGroupCoverage cgc WITH (NOLOCK) 
		LEFT JOIN mno.Operator o WITH (NOLOCK)  ON cgc.OperatorId = o.OperatorId
		LEFT JOIN mno.Country c WITH (NOLOCK)  ON cgc.Country = c.CountryISO2alpha
		-- to get RoutingPlanName
		LEFT JOIN rt.RoutingPlan rp WITH (NOLOCK) ON rp.RoutingPlanId = cgc.RoutingPlanId
		-- to get PricingPlanName
		LEFT JOIN rt.PricingPlan pp WITH (NOLOCK)  ON pp.PricingPlanId = cgc.PricingPlanId
		-- to get TierLevelCurrent
		LEFT JOIN rt.RoutingGroup rg WITH (NOLOCK)  ON rg.RoutingGroupId = cgc.RoutingGroupId AND rg.Deleted = 0
		-- to get L1_ConnSummary
		--LEFT JOIN rt.RoutingGroupTier rgtL1 ON rgtL1.RoutingGroupId = cgc.RoutingGroupId AND rgtL1.Level = 1 AND rgtL1.Deleted = 0
		LEFT JOIN rt.RoutingTier rtL1 WITH (NOLOCK)  ON cgc.RoutingGroupId = rtL1.RoutingTierId AND rtL1.TierLevel = 1 AND rtL1.Deleted = 0

	WHERE (cgc.CustomerGroupId = @CustomerGroupId AND cgc.Deleted = 0)
		AND cgc.TrafficCategory = 'DEF'
		AND ((@SubAccountUid IS NULL AND cgc.SubAccountUid IS NULL) OR 
			 (@SubAccountUid IS NOT NULL AND cgc.SubAccountUid = @SubAccountUid))

	-- attach data for routing groups and tiers
	IF @OutputTiers = 1
	BEGIN
		DECLARE @RoutingGroups TABLE (
			RoutingGroupId int PRIMARY KEY
		)

		INSERT INTO @RoutingGroups (RoutingGroupId)
		SELECT DISTINCT RoutingGroupId
		FROM rt.CustomerGroupCoverage cgc WITH (NOLOCK) 
		WHERE cgc.CustomerGroupId = @CustomerGroupId AND cgc.Deleted = 0
			AND ((@SubAccountUid IS NULL AND cgc.SubAccountUid IS NULL) OR 
				 (@SubAccountUid IS NOT NULL AND cgc.SubAccountUid = @SubAccountUid))
			AND cgc.RoutingGroupId IS NOT NULL

		-- cgc.CoverageId is not added here. It can be added based on request from API team.
		SELECT rg.RoutingGroupId, rg.RoutingGroupName,
			rt.RoutingTierId AS RoutingTierId, rt.RoutingTierName AS RoutingTierName, rt.TierLevel AS RoutingTierLevel,
			IIF(SUM(CAST(rtc.Active as tinyint)) OVER (PARTITION BY rt.RoutingTierId) > 0, 1, 0) AS RoutingTierStatus,
			rtc.TierEntryId, rtc.ConnUid, cc.RouteId AS ConnId, rtc.Weight, rtc.Active
		FROM rt.RoutingGroup rg WITH (NOLOCK) 
			--INNER JOIN rt.RoutingGroupTier rgt ON rgt.RoutingGroupId = rg.RoutingGroupId AND rgt.Deleted = 0
			INNER JOIN rt.RoutingTier rt WITH (NOLOCK) ON rg.RoutingGroupId = rt.RoutingGroupId AND rt.Deleted = 0
			INNER JOIN rt.RoutingTierConn rtc WITH (NOLOCK) ON rtc.RoutingTierId = rt.RoutingTierId AND rtc.Deleted = 0
			INNER JOIN dbo.CarrierConnections cc WITH (NOLOCK) ON rtc.ConnUid = cc.RouteUid
		WHERE rg.Deleted = 0 AND rg.RoutingGroupId IN (SELECT RoutingGroupId FROM @RoutingGroups)
	END
END
