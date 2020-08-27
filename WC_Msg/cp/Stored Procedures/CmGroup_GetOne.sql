
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-02-02
-- =============================================
-- EXEC cp.CmGroup_GetOne @AccountUid='499250FE-E2E5-E611-813F-06B9B96CA965', @GroupId=2
-- EXEC cp.CmGroup_GetOne @AccountUid='499250FE-E2E5-E611-813F-06B9B96CA965', @GroupId=2, @OutputCountries = 1
CREATE PROCEDURE [cp].[CmGroup_GetOne]
	@AccountId varchar(50) = NULL,			-- one of @AccountId or @AccountUid must be specified
	@AccountUid uniqueidentifier = NULL,	
	@GroupId int,
	@OutputCountries bit = 0
AS
BEGIN
	
	SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)
	
	SELECT TOP (1) g.GroupId, g.GroupName, g.GroupDescription, g.ContactsCount, g.CreatedAt, g.CreatedBy, u.Login as CreatedBy_Username
	FROM cp.CmGroup g
		LEFT JOIN cp.[User] u ON g.CreatedBy = u.UserId
	WHERE g.GroupId = @GroupId AND g.AccountUid = @AccountUid AND g.DeletedAt IS NULL

	IF @@ROWCOUNT = 1 AND @OutputCountries = 1
	BEGIN
		SELECT c.Country, COUNT(*) AS Count
		FROM cp.CmGroupContact gc
			INNER JOIN cp.CmContact c ON gc.ContactId = c.ContactId
		WHERE gc.GroupId = @GroupId AND c.DeletedAt IS NULL
		GROUP BY c.Country
	END

END

