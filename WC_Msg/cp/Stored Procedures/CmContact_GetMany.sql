-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- =============================================
-- EXEC cp.CmContact_GetMany @AccountUid='BB06841D-6182-E711-8143-02D85F55FCE7', @Offset = 0, @SearchQuery = '+61491867', @OutputGroups = 1, @OutputFields = 1
-- EXEC cp.CmContact_GetMany @AccountUid='499250FE-E2E5-E611-813F-06B9B96CA965', @OutputGroups = 1, @OutputFields = 1
CREATE PROCEDURE [cp].[CmContact_GetMany]
	@AccountId varchar(50) = NULL,			-- one of @AccountId or @AccountUid must be specified
	@AccountUid uniqueidentifier = NULL,	
	@GroupId int = NULL,	-- Filter by GroupId
	@SearchQuery varchar(16) = NULL,
	@Offset int = 0,
	@Limit int = 200,
	@OutputGroups bit = 0,
	@OutputFields bit = 0,
	@OutputTotals bit = 0
AS
BEGIN
	
	SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)
	
	IF @Limit > 1000 SET @Limit = 1000

	DECLARE @Contacts TABLE (ContactId INT NOT NULL UNIQUE)

	INSERT INTO @Contacts (ContactId)
	SELECT c.ContactId
	FROM cp.CmContact c (NOLOCK)
	WHERE c.AccountUid = @AccountUid AND c.DeletedAt IS NULL 
		AND (@GroupId IS NULL OR (@GroupId IS NOT NULL AND EXISTS (SELECT 1 FROM cp.CmGroupContact gc (NOLOCK) WHERE gc.GroupId = @GroupId AND gc.ContactId = c.ContactId)))
		AND (@SearchQuery IS NULL OR (@SearchQuery IS NOT NULL AND LEFT(c.MSISDN, LEN(@SearchQuery)) = @SearchQuery))
	ORDER BY c.ContactId DESC
	OFFSET (@Offset) ROWS FETCH NEXT (@Limit) ROWS ONLY

	SELECT c.ContactId, c.MSISDN, Country, c.CreatedAt, c.CreatedBy, u.Login as CreatedBy_Username, 
		cfFirstname.FieldValue AS Firstname, cfSurname.FieldValue AS Surname
	FROM cp.CmContact c WITH (NOLOCK)
		INNER JOIN @Contacts cv ON c.ContactId = cv.ContactId
		LEFT JOIN cp.[User] u WITH (NOLOCK) ON c.CreatedBy = u.UserId
		LEFT JOIN cp.CmContactField cfFirstname WITH (NOLOCK) ON c.ContactId = cfFirstname.ContactId AND cfFirstname.FieldName = 'Firstname' AND cfFirstname.DeletedAt IS NULL
		LEFT JOIN cp.CmContactField cfSurname WITH (NOLOCK) ON c.ContactId = cfSurname.ContactId AND cfSurname.FieldName = 'Surname' AND cfSurname.DeletedAt IS NULL
	ORDER BY c.ContactId DESC

	-- Get extra groups
	IF @OutputGroups = 1
		SELECT gc.ContactId, g.GroupId, g.GroupName
		FROM cp.CmGroupContact gc
			INNER JOIN cp.CmGroup g (NOLOCK) ON gc.GroupId = g.GroupId
			INNER JOIN @Contacts cv ON gc.ContactId = cv.ContactId
		WHERE g.DeletedAt IS NULL
		
	-- Get extra fields
	IF @OutputFields = 1
		SELECT cf.ContactId, cf.FieldName, cf.FieldValue 
		FROM cp.CmContactField cf WITH (NOLOCK)
			INNER JOIN @Contacts cv ON cf.ContactId = cv.ContactId
		WHERE cf.DeletedAt IS NULL

	-- Get totals
	IF @OutputTotals = 1
		SELECT TotalContactsActive
		FROM cp.CmSummary WITH (NOLOCK)
		WHERE AccountUid = @AccountUid
END
