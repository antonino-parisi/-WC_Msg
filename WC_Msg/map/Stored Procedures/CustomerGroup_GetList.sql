-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-12-21
-- =============================================
-- EXEC map.CustomerGroup_GetList @CustomerGroupId = 234, @SubAccountUid = 18306
-- EXEC map.CustomerGroup_GetList @CustomerGroupId = NULL, @SubAccountUid = 18306
CREATE PROCEDURE [map].[CustomerGroup_GetList]
	@CustomerGroupId int = NULL,	--optional
	@SubAccountUid int = NULL		--optional
AS
BEGIN

	SELECT cg.CustomerGroupId, cg.CustomerGroupName, cg.Description,
		ISNULL(cnt.SubAccountQty, 0) AS SubAccountQty,
		cg.OwnerId, u.Email AS Owner_Email, u.Firstname AS Owner_Firstname, u.LastName AS Owner_Lastname
	FROM rt.CustomerGroup cg
		LEFT JOIN map.[User] u ON u.UserId = cg.OwnerId
		LEFT JOIN (
			SELECT CustomerGroupId, COUNT(SubAccountUid) AS SubAccountQty
			FROM rt.CustomerGroupSubAccount cgs 
            WHERE cgs.Deleted = 0
			GROUP BY CustomerGroupId) cnt ON cg.CustomerGroupId = cnt.CustomerGroupId
	WHERE (@CustomerGroupId IS NULL OR (@CustomerGroupId IS NOT NULL AND cg.CustomerGroupId = @CustomerGroupId))
		AND cg.Deleted = 0
		AND (@SubAccountUid IS NULL OR (@SubAccountUid IS NOT NULL 
			AND EXISTS (SELECT 1 FROM rt.CustomerGroupSubAccount WHERE SubAccountUid = @SubAccountUid AND cg.CustomerGroupId = CustomerGroupId AND Deleted = 0)))
END
