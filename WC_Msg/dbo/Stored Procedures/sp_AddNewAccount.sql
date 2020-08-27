

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	 this SP is used by admin and customer portal to create new Account
-- =============================================
CREATE PROCEDURE [dbo].[sp_AddNewAccount]
	@AccountName NVARCHAR(50),
	@Password NVARCHAR(50),
	@Description NVARCHAR(MAX),
	@ValidationTag NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	THROW 52001, 'This method of account creation is banned as deprecated. Please use MAP', 1;
	
	-- Not really secure but enough ?
	
 --   INSERT INTO dbo.AccountCredentials (AccountId,Password,isEncrypted,date,Description,overdraftAuthorized,ValidationTag,IsVerified) values (@AccountName,@Password,0,CURRENT_TIMESTAMP,@Description,0,@ValidationTag,0);

	--INSERT INTO dbo.AccountCredit (AccountId,CreditEuro) values (@AccountName,0)

	--INSERT INTO dbo.AccountBillingInformation (AccountId,AccountInformation,NextBillingDate,SubscriptionDate) VALUES (@AccountName, 'New Account', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);
	
	--IF @Description = 'Account from Admin page'
	--BEGIN
	--	INSERT INTO cp.Account (AccountId, AccountName, CompanyName, FreeCreditsOffer) 
	--		VALUES (@AccountName, @AccountName, @AccountName, 2)
		
	--	INSERT INTO ms.AuthApi (ApiKey, AccountId, Name, Active, CreatedAt)
	--	SELECT dbo.fnGenerateRandomString(30) as ApiKey, @AccountName, 'apiKey 1' as Name, 1 as Active, GETUTCDATE() as CreatedAt
	--END
END
