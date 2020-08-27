
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-09-23
-- Description:	Get emails for Subaccount
-- =============================================
-- Examples:
--	EXEC [rt].[Account_GetEmailsBySubAccount] @SubAccountID='clxnetworks_1', @Action='PriceChangeNotification'
-- =============================================
CREATE PROCEDURE [rt].[Account_GetEmailsBySubAccount]
	@SubAccountId varchar(50),
	@Action varchar(10)
AS
BEGIN

	/*
	SELECT 'TO' AS Part, 'marc.magnin@wavecell.com' as EmailAddress
	UNION
	SELECT 'TO' AS Part, 'lee.vidor@wavecell.com' as EmailAddress
	UNION
	SELECT 'CC', 'raymond.torino@wavecell.com'
	UNION
	SELECT 'CC' AS Part, 'anton.shchekalov@wavecell.com' as EmailAddress
	*/
	
	WITH emails (EmailAddress, CCEmailAddress, BCCEmailAddress)
	AS (
		SELECT EmailAddress, CCEmailAddress, BCCEmailAddress
		FROM dbo.[Users] u
			INNER JOIN dbo.Account a ON a.AccountId = u.AccountId
		WHERE a.SubAccountId = @SubAccountId
	)

	SELECT 'TO' as Part, EmailAddress						FROM emails WHERE EmailAddress IS NOT NULL
	UNION ALL
	SELECT 'CC' as Part, CCEmailAddress AS EmailAddress		FROM emails WHERE CCEmailAddress IS NOT NULL 
	UNION ALL
	SELECT 'BCC' as Part, BCCEmailAddress AS EmailAddress	FROM emails WHERE BCCEmailAddress IS NOT NULL
	
END
