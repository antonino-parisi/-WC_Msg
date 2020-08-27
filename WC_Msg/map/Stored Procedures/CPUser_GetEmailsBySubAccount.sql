-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-04-27
-- Updated By:  Nathanael Hinay
-- Date:        2018-08-17
-- Description:	Emails of Accounts for pricing notifications
-- =============================================
-- Examples:
--	EXEC map.[CPUser_GetEmailsBySubAccount] @SubAccountUid = 123, @Action='Pricelist'
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 07/12/2018  Nathanael  added Type to response

CREATE PROCEDURE [map].[CPUser_GetEmailsBySubAccount]
	@SubAccountUid int,
	@Action varchar(10) = 'Pricelist'
AS
BEGIN

	WITH emails (EmailAddress, CCEmailAddress, BCCEmailAddress)
	AS (
		SELECT EmailAddress, CCEmailAddress, BCCEmailAddress
		FROM dbo.[Users] u
			INNER JOIN cp.Account c ON c.AccountId = u.AccountId
			INNER JOIN dbo.Account sa ON sa.AccountId = c.AccountId
		WHERE sa.SubAccountUid = @SubAccountUid
		UNION
		SELECT Email, NULL, NULL
		FROM cp.AccountEmail ae
			INNER JOIN cp.Account c ON c.AccountUid = ae.AccountUid
			INNER JOIN dbo.Account sa ON sa.AccountId = c.AccountId
		WHERE sa.SubAccountUid = @SubAccountUid AND FlagPricing = 1
	)

	SELECT EmailAddress	AS Email, 'To' as Type FROM emails WHERE EmailAddress IS NOT NULL
	UNION
	SELECT CCEmailAddress AS Email, 'CC' as Type FROM emails WHERE CCEmailAddress IS NOT NULL 
	UNION
	SELECT BCCEmailAddress AS Email, 'BCC' as Type	FROM emails WHERE BCCEmailAddress IS NOT NULL
	UNION
	SELECT 'pricelists@wavecell.com' Email, 'BCC' as Type
	
END

