
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017/07/18
-- Description:	Get subaccounts with defaults plans
-- =============================================
-- EXEC [rt].[SubAccount_GetAll] @LastSyncTimestamp = '2017-08-01'
CREATE PROCEDURE [rt].[SubAccount_GetAll]
	@LastSyncTimestamp datetime = NULL
WITH EXECUTE AS 'dbo'
AS
BEGIN
	--DECLARE @LastSyncTimestamp datetime = '2020-07-28'

	SELECT a.SubAccountUid, a.SubAccountId, a.Deleted, 
		IIF(s.Deleted = 0, s.RoutingPlanId_Default, NULL) AS RoutingPlanId_Default, 
		IIF(s.Deleted = 0, s.PricingPlanId_Default, NULL) AS PricingPlanId_Default
	FROM dbo.Account a 
		LEFT JOIN rt.SubAccount_Default s ON s.SubAccountUid = a.SubAccountUid
	WHERE ((@LastSyncTimestamp IS NULL AND a.Deleted = 0) 
		OR (@LastSyncTimestamp IS NOT NULL AND 
			(a.UpdatedAt >= @LastSyncTimestamp OR s.UpdatedAt >= @LastSyncTimestamp)
		))
END

