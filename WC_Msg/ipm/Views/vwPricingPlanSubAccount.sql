CREATE VIEW ipm.vwPricingPlanSubAccount
AS
	SELECT sa.AccountId, sa.CustomerType, ppsa.SubAccountUid, sa.SubAccountId, pp.PricingPlanName, ppsa.PeriodStart, ppsa.PeriodEnd, sa.BillingMode, sa.Currency, sa.Manager, sa.BU
	FROM ipm.PricingPlanSubAccount AS ppsa 
		INNER JOIN ms.vwSubAccount AS sa ON ppsa.SubAccountUid = sa.SubAccountUid
		INNER JOIN ipm.PricingPlan AS pp ON ppsa.PricingPlanId = pp.PricingPlanId
