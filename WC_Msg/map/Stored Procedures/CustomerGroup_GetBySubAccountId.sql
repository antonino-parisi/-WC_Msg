-- =============================================
-- Author:		Nathanael Hinay
-- Create date: 2018-06-22
-- =============================================
-- EXEC map.CustomerGroup_GetBySubAccountId @SubAccountId = 'AcmeCorp-0aA4C_hq'
CREATE PROCEDURE [map].[CustomerGroup_GetBySubAccountId]
	@SubAccountId varchar(50)
AS
BEGIN
    SELECT cgs.CustomerGroupId,
        cg.CustomerGroupName,
        cg.Description,
        cgs.SubAccountUid,
        a.SubAccountId,
    	ISNULL(cnt.SubAccountQty, 0) AS SubAccountQty,
        cg.OwnerId, u.Email AS Owner_Email, u.Firstname AS Owner_Firstname, u.LastName AS Owner_Lastname
    FROM [rt].[CustomerGroupSubAccount] cgs
        INNER JOIN dbo.Account a ON cgs.SubAccountUid = a.SubAccountUid
        INNER JOIN rt.CustomerGroup cg ON cgs.CustomerGroupId = cg.CustomerGroupId
        LEFT JOIN map.[User] u ON u.UserId = cg.OwnerId
        LEFT JOIN (
			SELECT CustomerGroupId, COUNT(SubAccountUid) AS SubAccountQty
			FROM rt.CustomerGroupSubAccount cgs 
            WHERE cgs.Deleted = 0
			GROUP BY CustomerGroupId) cnt ON cg.CustomerGroupId = cnt.CustomerGroupId
    WHERE a.SubAccountId=@SubAccountId AND cg.Deleted = 0 AND cgs.Deleted = 0 AND a.Deleted = 0
END
