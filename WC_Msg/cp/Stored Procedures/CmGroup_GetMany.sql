
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-02-02
-- =============================================
-- EXEC cp.CmGroup_GetMany @AccountUid='47E0E533-14F0-E611-813F-06B9B96CA965', @OutputTotals = 1
CREATE PROCEDURE [cp].[CmGroup_GetMany]
	@AccountId varchar(50) = NULL,			-- one of @AccountId or @AccountUid must be specified
	@AccountUid uniqueidentifier = NULL,
	@Offset int = 0,
	@Limit int = 200,
	@OutputTotals bit = 0
AS
BEGIN
	
	SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)
	
	IF @Limit > 1000 SET @Limit = 1000

	SELECT g.GroupId, g.GroupName, g.GroupDescription, g.ContactsCount, g.CreatedAt, g.CreatedBy, u.Login as CreatedBy_Username
	FROM cp.CmGroup g
		LEFT JOIN cp.[User] u ON g.CreatedBy = u.UserId
	WHERE g.AccountUid = @AccountUid AND g.DeletedAt IS NULL
	ORDER BY g.GroupId DESC
	OFFSET (@Offset) ROWS FETCH NEXT (@Limit) ROWS ONLY

	-- Get totals
	IF @OutputTotals = 1
		SELECT COUNT(1) AS TotalActiveGroups
		FROM cp.CmGroup
		WHERE AccountUid = @AccountUid AND DeletedAt IS NULL
END

