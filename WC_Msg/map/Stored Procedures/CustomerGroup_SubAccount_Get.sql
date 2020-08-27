-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-03-05
-- Updated by:   Raymond Torino
-- Updated date: 2018-03-22
-- =============================================
-- EXEC map.CustomerGroup_SubAccount_Get @CustomerGroupId = 4
CREATE PROCEDURE [map].[CustomerGroup_SubAccount_Get]
	@CustomerGroupId int
AS
BEGIN

	SELECT cgs.CustomerGroupId, cgs.SubAccountUid, a.SubAccountId, a.AccountId, cgs.UpdatedAt
	FROM [rt].[CustomerGroupSubAccount] cgs
		INNER JOIN dbo.Account a ON cgs.SubAccountUid = a.SubAccountUid
	WHERE cgs.CustomerGroupId = @CustomerGroupId AND cgs.Deleted = 0
END
