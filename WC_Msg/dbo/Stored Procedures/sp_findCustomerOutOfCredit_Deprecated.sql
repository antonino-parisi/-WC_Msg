
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	find the account where the credit is less thant the alert value ( not used)
-- =============================================
CREATE PROCEDURE [dbo].[sp_findCustomerOutOfCredit_Deprecated]
AS
BEGIN

	SELECT Users.Username, AccountCredentials.AccountId, AccountCredentials.AlertValue, AccountCredit.CreditEuro
	FROM Users, AccountCredentials, AccountCredit (NOLOCK)
	WHERE Users.AccountId = AccountCredit.AccountId AND
		  AccountCredentials.AccountId = AccountCredit.AccountId AND
		  OutOfCredit = 0 AND
		  AccountCredit.CreditEuro < AccountCredentials.AlertValue;
END
