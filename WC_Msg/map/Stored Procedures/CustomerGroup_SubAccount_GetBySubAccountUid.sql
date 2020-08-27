-- =============================================
-- Author:		Raymond Torino
-- Create date: 	2018-03-22
-- =============================================
-- EXEC map.CustomerGroup_SubAccount_GetBySubAccountUid @SubAccountUid = 18306
CREATE PROCEDURE [map].[CustomerGroup_SubAccount_GetBySubAccountUid]
	@SubAccountUid int
AS
BEGIN

	-- Ideally, a sub-account can only belong to one customer group, we'll just select one that recently updated
	SELECT TOP 1 cgs.CustomerGroupId, cgs.SubAccountUid, a.SubAccountId, a.AccountId, cgs.UpdatedAt, cgs.Deleted
	FROM rt.CustomerGroupSubAccount cgs
		INNER JOIN dbo.Account a ON cgs.SubAccountUid = a.SubAccountUid
	WHERE cgs.SubAccountUid = @SubAccountUid AND cgs.Deleted = 0
	ORDER BY cgs.UpdatedAt DESC

END
