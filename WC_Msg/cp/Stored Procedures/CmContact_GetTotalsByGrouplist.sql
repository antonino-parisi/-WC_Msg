
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-02-02
-- =============================================
-- EXEC cp.CmContact_GetTotalsByGrouplist @AccountUid='5C9250FE-E2E5-E611-813F-06B9B96CA965', @GroupIds = '249,250'
CREATE PROCEDURE [cp].[CmContact_GetTotalsByGrouplist]
	@AccountUid uniqueidentifier,
	@GroupIds varchar(1000)
AS
BEGIN
	
	--SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)
	DECLARE @GroupT TABLE (ID INT PRIMARY KEY)
	INSERT INTO @GroupT (ID) 
	SELECT g.GroupId 
	FROM dbo.SplitString_Int(@GroupIds, ',') s
		INNER JOIN cp.CmGroup g ON s.Item = g.GroupId
	WHERE g.AccountUid = @AccountUid AND g.DeletedAt IS NULL

	SELECT COUNT(DISTINCT gc.ContactId) AS ContactsUniqueCount, COUNT(gc.ContactId) - COUNT(DISTINCT gc.ContactId) ContactsDuplicatesCount
	FROM cp.CmContact c
		INNER JOIN cp.CmGroupContact gc ON c.ContactId = gc.ContactId
	WHERE c.AccountUid = @AccountUid AND c.DeletedAt IS NULL
		AND gc.GroupId IN (SELECT ID FROM @GroupT)

	SELECT c.Country, COUNT(1) AS ContactsCount
	FROM cp.CmContact c
	WHERE c.AccountUid = @AccountUid AND c.DeletedAt IS NULL
		AND EXISTS (
			SELECT 1 FROM cp.CmGroupContact gc 
			WHERE gc.ContactId = c.ContactId AND gc.GroupId IN (SELECT ID FROM @GroupT)
		)
	GROUP BY c.Country
	ORDER BY 2 DESC
	
END

