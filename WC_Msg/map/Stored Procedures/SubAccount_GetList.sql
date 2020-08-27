-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-02-28
-- Updated by:   Raymond Torino
-- Updated date: 2018-03-22
-- =============================================
-- EXEC map.SubAccount_GetList @NoCustomerGroupLink = 1
CREATE PROCEDURE [map].[SubAccount_GetList]
	@SubAccountIdStarts varchar(50) = NULL,	-- optional filter: search by starting in SubAccountId name
	@NoCustomerGroupLink bit = 0		-- optional filter: 1 - to filter subaccounts without any customergroup attached
AS
BEGIN

	SELECT a.SubAccountUid, a.SubAccountId
	FROM dbo.Account a
	WHERE a.Deleted = 0 AND a.Active = 1
		-- filtering for @SubAccountIdStarts
		AND (@SubAccountIdStarts IS NULL OR 
				(@SubAccountIdStarts IS NOT NULL AND a.SubAccountId LIKE @SubAccountIdStarts + '%')
			)
		-- filtering for @NoCustomerGroupLink
		AND (@NoCustomerGroupLink <> 1  OR (@NoCustomerGroupLink = 1 AND 
			NOT EXISTS (SELECT 1 FROM rt.CustomerGroupSubAccount WHERE SubAccountUid = a.SubAccountUid AND Deleted = 0)))

END
