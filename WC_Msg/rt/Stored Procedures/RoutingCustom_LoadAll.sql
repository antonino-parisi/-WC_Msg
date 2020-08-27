-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-03
-- =============================================
-- EXEC rt.RoutingCustom_LoadAll @LastSyncTimestamp = '2017-08-01'
CREATE PROCEDURE [rt].[RoutingCustom_LoadAll]
	@LastSyncTimestamp datetime = NULL
AS
BEGIN
	SELECT 
		rc.Id, 
		rc.SubAccountUid, 
		rc.Country, rc.OperatorId, 
		rc.TrafficCategory,
		rc.RoutingGroupId, 
		rc.PriceCurrency, -- deprecated, EUR only
		IIF(rc.MarginRate IS NOT NULL, 'M', 'F') AS PricingMethod, 
		rc.Price, 
		rc.MarginRate AS Margin, 
		rc.CostCurrency, rc.CostCalculated, 
		rc.CompanyCurrency, rc.CompanyPrice,	-- deprecated
		rc.Price AS PriceContract,
		rc.PriceCurrency AS PriceContractCurrency,
		rc.PricingFormulaId, 
		rc.Deleted
	FROM rt.RoutingCustom rc
	WHERE ((@LastSyncTimestamp IS NULL AND rc.Deleted = 0) OR (@LastSyncTimestamp IS NOT NULL AND rc.UpdatedAt >= @LastSyncTimestamp))
END