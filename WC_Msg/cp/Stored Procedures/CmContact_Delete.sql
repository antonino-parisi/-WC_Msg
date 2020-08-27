
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- =============================================
-- EXEC cp.CmContact_Delete @AccountId='AcmeCorp-0aA4C', @MSISDN=79119102182, @DeletedBy = 'E9BCBF9B-CDC9-4BA6-8C4B-92B41C7F280D'
CREATE PROCEDURE [cp].[CmContact_Delete]
	@AccountId varchar(50) = NULL,
	@AccountUid uniqueidentifier = NULL, -- one of @AccountId or @AccountUid must be specified
	@MSISDN bigint,					-- yes, it's Int64, not string
	@DeletedBy uniqueidentifier		-- UserId that creates record
AS
BEGIN
	
	SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)

	DECLARE @ContactT TABLE (ContactId int PRIMARY KEY)

	UPDATE cp.CmContact
	SET DeletedAt = GETUTCDATE(), DeletedBy = @DeletedBy
	OUTPUT deleted.ContactId INTO @ContactT(ContactId)
	WHERE AccountUid = @AccountUid AND MSISDN = @MSISDN AND DeletedAt IS NULL

	UPDATE g SET ContactsCount -= 1
	FROM cp.CmGroupContact gc
		INNER JOIN cp.CmGroup g ON g.GroupId = gc.GroupId
		INNER JOIN @ContactT c ON gc.ContactId = c.ContactId

	-- Update summary
	UPDATE cp.CmSummary
	SET TotalContactsActive -= (SELECT COUNT(ContactId) FROM @ContactT)
	WHERE AccountUid = @AccountUid
END
