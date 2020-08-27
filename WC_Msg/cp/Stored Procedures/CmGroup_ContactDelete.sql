
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- =============================================
-- EXEC cp.[CmGroup_ContactDelete] @AccountId='AcmeCorp-0aA4C', @GroupId=2, @MSISDN=79119102181
CREATE PROCEDURE [cp].[CmGroup_ContactDelete]
	@AccountId varchar(50) = NULL,		-- one of @AccountId or @AccountUid must be specified
	@AccountUid uniqueidentifier = NULL, 
	@GroupId int,
	@ContactId int = NULL,		-- one of @ContactId or @MSISDN must be set
	@MSISDN bigint  = NULL
AS
BEGIN
	
	SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)

	-- lookup for @ContactId
	IF @ContactId IS NULL
		SELECT @ContactId = ContactId FROM cp.CmContact WHERE AccountUid = @AccountUid AND DeletedAt IS NULL AND MSISDN = @MSISDN
	
	DELETE FROM gc
	FROM cp.CmGroup AS g
		INNER JOIN cp.CmGroupContact gc ON g.GroupId = gc.GroupId
	WHERE gc.GroupId = @GroupId AND ContactId = @ContactId
		AND g.AccountUid = @AccountUid

	IF @@ROWCOUNT > 0
		UPDATE cp.CmGroup SET ContactsCount -= 1 WHERE GroupId = @GroupId
END
