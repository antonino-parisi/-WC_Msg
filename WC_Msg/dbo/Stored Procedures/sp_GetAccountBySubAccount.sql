
-- =============================================
-- Author:		Raju
-- Create date: <Create Date,,>
-- Description:	return the account corresponding to a subaccount
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetAccountBySubAccount]  
	@SubAccountId NVARCHAR(50)
AS
BEGIN
	SELECT TOP (1) AccountId FROM dbo.[Account] WHERE SubAccountId = @SubAccountId
END