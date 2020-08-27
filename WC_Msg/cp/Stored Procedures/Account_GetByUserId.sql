-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-18
-- =============================================
-- EXEC cp.Account_GetByUserId @UserId='79B91B38-75AE-4A40-93D9-1D1C56369F99', @AccountId='ValidAcount-7wWA0'
CREATE PROCEDURE [cp].[Account_GetByUserId]
	@UserId uniqueidentifier,
	@AccountId varchar(50) -- to be flexible if one User might join multiple accounts in future
AS
BEGIN

	SELECT a.AccountId, a.AccountName, 
		a.CompanyName, a.Country, a.CompanyAddress, a.InvoiceEmails,
		a.FreeCreditsOffer,
		a.Product_SMS, a.Product_CA, a.Product_VI, a.Product_VO 
	FROM cp.Account a
	WHERE a.AccountId = @AccountId AND EXISTS (SELECT 1 FROM cp.[User] WHERE UserId = @UserId AND AccountId = @AccountId)

END
