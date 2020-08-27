
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-09
-- =============================================
-- EXEC cp.CmContact_GetManyByGrouplist @AccountUid='5C9250FE-E2E5-E611-813F-06B9B96CA965', @GroupIds = '249,250', @Offset = 10000, @Limit = 10000
CREATE PROCEDURE [cp].[CmContact_GetManyByGrouplist]
	@AccountUid uniqueidentifier,
	@GroupIds varchar(1000),
	@Offset int = 0,
	@Limit int = 200
AS
BEGIN
	
	--SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)
	
	IF @Limit > 10000 SET @Limit = 10000

	-- Get table with GroupIds
	DECLARE @GroupT TABLE (ID INT PRIMARY KEY)
	INSERT INTO @GroupT (ID) 
	SELECT g.GroupId 
	FROM dbo.SplitString_Int(@GroupIds, ',') s
		INNER JOIN cp.CmGroup g ON s.Item = g.GroupId
	WHERE g.AccountUid = @AccountUid AND g.DeletedAt IS NULL

	--Get MSISDNs for selected groups
	SELECT c.MSISDN
	FROM cp.CmContact c
	WHERE c.AccountUid = @AccountUid AND c.DeletedAt IS NULL
		AND EXISTS (
			SELECT 1 FROM cp.CmGroupContact gc 
			WHERE gc.ContactId = c.ContactId AND gc.GroupId IN (SELECT ID FROM @GroupT)
		)
	ORDER BY c.ContactId
	OFFSET (@Offset) ROWS FETCH NEXT (@Limit) ROWS ONLY

END

