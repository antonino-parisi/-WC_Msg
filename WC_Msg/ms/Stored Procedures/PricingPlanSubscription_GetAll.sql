-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-12-28
-- Description:	Load all message pricing plan from ipm.PricingPlanSubscription
-- =============================================
CREATE PROCEDURE [ms].[PricingPlanSubscription_GetAll]
AS
BEGIN
	SELECT
		AccountId,
		ImmediateBilling,
		MonthlyActiveUsers,
		ExtraUserFeeEUR,
		ExtraUserFeeContract,
		InboundMessageFeeEUR,
		InboundMessageFeeContract,
		OutboundMessageFeeEUR,
		OutboundMessageFeeContract,
		ContractCurrency
	FROM ipm.PricingPlanSubscription
END
