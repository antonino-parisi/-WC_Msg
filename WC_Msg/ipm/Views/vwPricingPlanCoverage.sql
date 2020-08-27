CREATE VIEW [ipm].[vwPricingPlanCoverage]
AS
	SELECT 
		a.AccountUid, a.AccountId,
		ppsa.SubAccountUid, sa.SubAccountId,
		ppsa.PeriodStart, ppsa.PeriodEnd, 
		ppsa.PricingPlanId, pp.PricingPlanName,
		ppsa.CreatedAt AS SubAccountPlan_CreatedAt,
		ppc.CoverageId, 
		ppc.ChannelTypeId, ch.ChannelType, ch.ChannelTypeName, 
		ppc.ContentTypeCode, 
		ppc.Country, c.CountryName,
		ppc.PeriodStart AS UnitPrice_PeriodStart, ppc.PeriodEnd AS UnitPrice_PeriodEnd, 
		ppc.Currency, ppc.Price, ppc.CreatedAt AS UnitPrice_CreatedAt
	FROM ipm.PricingPlanCoverage ppc (NOLOCK)
		INNER JOIN ipm.PricingPlanSubAccount ppsa (NOLOCK) ON 
			ppc.PricingPlanId = ppsa.PricingPlanId 
			AND (ppsa.PeriodStart BETWEEN ppc.PeriodStart AND ppc.PeriodEnd
				OR ppsa.PeriodEnd BETWEEN ppc.PeriodStart AND ppc.PeriodEnd)
		INNER JOIN ipm.PricingPlan pp (NOLOCK) ON ppsa.PricingPlanId = pp.PricingPlanId
		INNER JOIN ms.SubAccount sa (NOLOCK) ON ppsa.SubAccountUid = sa.SubAccountUid
		INNER JOIN cp.Account a (NOLOCK) ON sa.AccountUid = a.AccountUid
		LEFT JOIN mno.Country c (NOLOCK) ON ppc.Country = c.CountryISO2alpha
		LEFT JOIN ipm.ChannelType ch (NOLOCK) ON ch.ChannelTypeId = ppc.ChannelTypeId
