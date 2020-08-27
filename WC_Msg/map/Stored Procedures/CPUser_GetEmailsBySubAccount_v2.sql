-- =============================================
-- Author:		Nathanael Hinay
-- Create date: 2020-07-14
-- =============================================
-- Examples:
--	EXEC map.[CPUser_GetEmailsBySubAccount] @SubAccountUid = 123, @Action='Pricelist'
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 07/14/2020  Nathanael  use cp.AccountEmail only table

CREATE PROCEDURE [map].[CPUser_GetEmailsBySubAccount_v2]
	@SubAccountUid int,
	@Action varchar(10) = 'Pricelist'
AS
BEGIN

    SELECT Email, Type
    FROM cp.AccountEmail ae
        INNER JOIN cp.Account c ON c.AccountUid = ae.AccountUid
        INNER JOIN dbo.Account sa ON sa.AccountId = c.AccountId
    WHERE sa.SubAccountUid = @SubAccountUid AND FlagPricing = 1
	UNION
	SELECT 'pricelists@wavecell.com' Email, 'BCC' as Type
	
END
