CREATE VIEW [rt].[vwSubAccount_Default]
AS
	SELECT a.SubAccountUid, a.SubAccountId,
			s.RoutingPlanId_Default, r.RoutingPlanName,
			s.PricingPlanId_Default, p.PricingPlanName
	FROM dbo.Account a 
		INNER JOIN rt.SubAccount_Default s ON s.SubAccountUid = a.SubAccountUid
		LEFT JOIN rt.RoutingPlan r ON s.RoutingPlanId_Default = r.RoutingPlanId
		LEFT JOIN rt.PricingPlan p ON s.PricingPlanId_Default = p.PricingPlanId
