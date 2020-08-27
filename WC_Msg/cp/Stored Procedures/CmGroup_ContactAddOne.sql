-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- Possible errors:
--    - if MSISDN is set but it doesn't exists in Contacts
--    - if ContactId doesn't exists or deleted or belongs to another AccountUid
-- =============================================
-- EXEC cp.[CmGroup_ContactAddOne] @AccountId='AcmeCorp-0aA4C', @GroupId=2, @MSISDN=79119102181
CREATE PROCEDURE [cp].[CmGroup_ContactAddOne]
	@AccountId varchar(50) = NULL,		-- one of @AccountId or @AccountUid must be specified
	@AccountUid uniqueidentifier = NULL, 
	@GroupId int,
	@ContactId int = NULL,		-- one of @ContactId or @MSISDN must be set
	@MSISDN bigint  = NULL
AS
BEGIN
	
    SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)

    -- Check if Group belongs to account
    IF NOT EXISTS (SELECT 1 FROM cp.CmGroup WHERE AccountUid = @AccountUid AND GroupId = @GroupId)
        THROW 51000, 'Contact group does not belong to account', 1;

	-- lookup and validation for @ContactId
	IF @ContactId IS NULL
		SELECT @ContactId = ContactId FROM cp.CmContact WHERE AccountUid = @AccountUid AND DeletedAt IS NULL AND MSISDN = @MSISDN
	ELSE
		SELECT @ContactId = ContactId FROM cp.CmContact WHERE AccountUid = @AccountUid AND DeletedAt IS NULL AND ContactId = @ContactId

	IF @ContactId IS NULL
		THROW 51001, 'Contact does not exist', 1;

	INSERT INTO cp.CmGroupContact(GroupId, ContactId)
	VALUES (@GroupId, @ContactId)

	IF @@ROWCOUNT > 0
		UPDATE cp.CmGroup SET ContactsCount += 1 WHERE GroupId = @GroupId
	
END
