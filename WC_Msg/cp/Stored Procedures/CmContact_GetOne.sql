
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- =============================================
-- EXEC cp.CmContact_GetOne @AccountId='AcmeCorp-0aA4C', @MSISDN=79119102181
-- EXEC cp.CmContact_GetOne @AccountUid='499250FE-E2E5-E611-813F-06B9B96CA965', @ContactId=2
CREATE PROCEDURE [cp].[CmContact_GetOne]
	@AccountId varchar(50) = NULL,			-- one of @AccountId or @AccountUid must be specified
	@AccountUid uniqueidentifier = NULL,	
	@MSISDN bigint = NULL,					-- one of MSISDN or ContactId must be specified
	@ContactId int = NULL,
	@OutputGroups bit = 1,
	@OutputFields bit = 1
AS
BEGIN
	
	SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)

	SELECT TOP (1) @ContactId = ContactId
	FROM cp.CmContact
	WHERE AccountUid = @AccountUid AND DeletedAt IS NULL AND (MSISDN = @MSISDN OR ContactId = @ContactId)

	IF (@ContactId IS NULL) RETURN

	SELECT TOP (1) ContactId, c.MSISDN, Country, c.CreatedAt, c.CreatedBy, u.Login as CreatedBy_Username
	FROM cp.CmContact c
		LEFT JOIN cp.[User] u ON c.CreatedBy = u.UserId
	WHERE ContactId = @ContactId --AND c.DeletedAt IS NULL

	IF @OutputGroups = 1
		SELECT g.GroupId, g.GroupName
		FROM cp.CmGroupContact gc
			INNER JOIN cp.CmGroup g ON gc.GroupId = g.GroupId
		WHERE ContactId = @ContactId AND g.DeletedAt IS NULL

	IF @OutputFields = 1
		SELECT FieldName, FieldValue 
		FROM cp.CmContactField cf
		WHERE cf.ContactId = @ContactId AND cf.DeletedAt IS NULL
END
