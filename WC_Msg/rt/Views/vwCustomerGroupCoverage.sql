

CREATE VIEW [rt].[vwCustomerGroupCoverage] 
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
		INNER JOIN rt.CustomerGroup cg (NOLOCK) ON cgc.CustomerGroupId = cg.CustomerGroupId AND cg.Deleted = 0
		LEFT JOIN dbo.Account sa (NOLOCK) ON sa.SubAccountUid = cgc.SubAccountUid
		LEFT JOIN mno.Country c on cgc.Country = c.CountryISO2alpha
		LEFT JOIN mno.Operator o on cgc.OperatorId = o.OperatorId
		LEFT JOIN rt.RoutingPlan rp on cgc.RoutingPlanId = rp.RoutingPlanId AND rp.Deleted = 0
		LEFT JOIN rt.RoutingGroup rg on cgc.RoutingGroupId = rg.RoutingGroupId AND rg.Deleted = 0
		LEFT JOIN rt.PricingPlan pp on cgc.PricingPlanId = pp.PricingPlanId AND pp.Deleted = 0
		LEFT JOIN map.[User] muc ON cgc.CreatedBy = muc.UserId
		LEFT JOIN map.[User] muu ON cgc.UpdatedBy = muu.UserId
