
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- Notes: Might throw error in cases:
--    - unidentified AccountUid or null
--    - record AccountUid + MSISDN already exists
-- =============================================
-- EXEC cp.CmContact_Create @AccountId='AcmeCorp-0aA4C', @MSISDN=79119102182, @Country='RU', @CreatedBy = 'E9BCBF9B-CDC9-4BA6-8C4B-92B41C7F280D'
CREATE PROCEDURE [cp].[CmContact_Create]
	@AccountId varchar(50) = NULL,
	@AccountUid uniqueidentifier = NULL, -- one of @AccountId or @AccountUid must be specified
	@MSISDN bigint,					-- yes, it's Int64, not string
	@Country char(2) = NULL,		-- Great If requesting app will identify Country Code (using libphone)
	@CreatedBy uniqueidentifier		-- UserId that creates record
AS
BEGIN
	
	SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)
	DECLARE @TotalRecordsCounter tinyint = 0
	DECLARE @ActiveRecordsCounter tinyint = 0
	DECLARE @ContactId int = NULL
	DECLARE @IsDeleted bit = NULL

	IF @AccountUid IS NULL
		THROW 51001, 'AccountUid does not exists', 1; 

	-- check values of exisiting record
	SELECT @ContactId = ContactId, @IsDeleted = IIF(DeletedAt IS NULL, 0, 1) 
	FROM cp.CmContact WHERE AccountUid = @AccountUid AND MSISDN = @MSISDN

	-- if new record
	IF @ContactId IS NULL
	BEGIN
		-- insert new record, with new ContactId even if same MSISDN existed and was deleted in past
		INSERT INTO cp.CmContact (AccountUid, MSISDN, Country, CreatedAt, CreatedBy)
		OUTPUT inserted.ContactId
		VALUES (@AccountUid, @MSISDN, @Country, GETUTCDATE(), @CreatedBy)

		SET @TotalRecordsCounter = 1
		SET @ActiveRecordsCounter = 1
	END
	-- if deleted record
	ELSE IF (@ContactId IS NOT NULL AND @IsDeleted = 1)
	BEGIN
		-- restore deleted record
		DECLARE @ContactT TABLE (ContactId int PRIMARY KEY)

		UPDATE cp.CmContact
		SET CreatedAt = GETUTCDATE(),
			CreatedBy = @CreatedBy,
			Country = ISNULL(@Country, Country),
			DeletedAt = NULL, DeletedBy = NULL
		OUTPUT inserted.ContactId INTO @ContactT(ContactId)
		WHERE ContactId = @ContactId

		SET @ActiveRecordsCounter = 1

		UPDATE g SET ContactsCount += @ActiveRecordsCounter
		FROM cp.CmGroupContact gc
			INNER JOIN cp.CmGroup g ON g.GroupId = gc.GroupId
			INNER JOIN @ContactT c ON gc.ContactId = c.ContactId

		SELECT ContactId FROM @ContactT
	END
	-- if exists active record
	ELSE IF (@ContactId IS NOT NULL AND @IsDeleted = 0)
	BEGIN
		-- update existing record
		UPDATE cp.CmContact 
		SET Country = @Country
		OUTPUT inserted.ContactId
		WHERE ContactId = @ContactId AND @Country IS NOT NULL
	END

	-- Update summary
	IF EXISTS (SELECT 1 FROM cp.CmSummary WHERE AccountUid = @AccountUid)
		UPDATE cp.CmSummary
		SET TotalContacts += @TotalRecordsCounter, TotalContactsActive += @ActiveRecordsCounter
		WHERE AccountUid = @AccountUid
	ELSE
		-- init insert
		INSERT INTO cp.CmSummary (AccountUid, TotalContacts, TotalContactsActive)
		SELECT AccountUid, COUNT(1) AS TotalContacts, COUNT(1) - COUNT(DeletedAt) AS TotalContactsActive
		FROM cp.CmContact
		WHERE AccountUid = @AccountUid
		GROUP BY AccountUid
END
