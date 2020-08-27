
CREATE VIEW [rpt].[vwCustomerGroupCoverageAll] 
AS
	SELECT cgc.*, 
		cg.CustomerGroupName, 
		sa.SubAccountId, sa.AccountId,
		c.CountryName, o.OperatorName,
		pp.PricingPlanName,
		rp.RoutingPlanName,
		rg.RoutingGroupName,
		rg.TierLevelCurrent,
		muc.Email AS CreatedBy_Email,
		muu.Email AS UpdatedBy_Email
	FROM rt.CustomerGroupCoverage cgc (NOLOCK)
		INNER JOIN rt.CustomerGroup cg (NOLOCK) ON cgc.CustomerGroupId = cg.CustomerGroupId
		LEFT JOIN dbo.Account sa (NOLOCK) ON sa.SubAccountUid = cgc.SubAccountUid
		LEFT JOIN mno.Country c (NOLOCK) on cgc.Country = c.CountryISO2alpha
		LEFT JOIN mno.Operator o (NOLOCK) on cgc.OperatorId = o.OperatorId
		LEFT JOIN rt.RoutingPlan rp (NOLOCK) on cgc.RoutingPlanId = rp.RoutingPlanId --AND rp.Deleted = 0
		LEFT JOIN rt.RoutingGroup rg (NOLOCK) on cgc.RoutingGroupId = rg.RoutingGroupId --AND rg.Deleted = 0
		LEFT JOIN rt.PricingPlan pp (NOLOCK) on cgc.PricingPlanId = pp.PricingPlanId --AND pp.Deleted = 0
		LEFT JOIN map.[User] muc (NOLOCK) ON cgc.CreatedBy = muc.UserId
		LEFT JOIN map.[User] muu (NOLOCK) ON cgc.UpdatedBy = muu.UserId


