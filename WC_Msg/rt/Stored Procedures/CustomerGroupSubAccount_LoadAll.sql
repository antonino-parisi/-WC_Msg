-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-04-04
-- =============================================
-- EXEC rt.CustomerGroup_LoadAll
CREATE PROCEDURE [rt].[CustomerGroupSubAccount_LoadAll]
	@LastSyncTimestamp datetime = NULL
AS
BEGIN
	SELECT cgs.CustomerGroupId, cgs.SubAccountUid, cgs.Deleted
	FROM rt.CustomerGroupSubAccount cgs
	WHERE ((@LastSyncTimestamp IS NULL AND cgs.Deleted = 0) 
		OR (@LastSyncTimestamp IS NOT NULL AND cgs.UpdatedAt >= @LastSyncTimestamp))
END
