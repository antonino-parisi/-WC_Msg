-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-31
-- Description:	Data for RoutingMatrix. Mapping of all Subaccounts and Accounts
-- =============================================
CREATE PROCEDURE dbo.sp_RoutingMatrix_PopulateAccountMatrix
AS
BEGIN

	SELECT SubAccountId, AccountId FROM dbo.Account

END
