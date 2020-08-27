-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- =============================================
-- EXEC cp.CmGroup_Create @AccountId='AcmeCorp-0aA4C', @GroupName='Group 1', @CreatedBy = 'E9BCBF9B-CDC9-4BA6-8C4B-92B41C7F280D'
CREATE PROCEDURE [cp].[CmGroup_Create]
	@AccountId varchar(50) = NULL,		-- one of @AccountId or @AccountUid must be specified
	@AccountUid uniqueidentifier = NULL, 
	@GroupName nvarchar(100),
	@GroupDescription nvarchar(1000) = NULL,
	@CreatedBy uniqueidentifier			-- UserId that created record
AS
BEGIN
	
	SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)

	IF EXISTS (SELECT 1 FROM cp.CmGroup WHERE AccountUid = @AccountUid AND GroupName = @GroupName AND DeletedAt IS NULL)
		THROW 51000, 'Group with same name already exists', 1;

	INSERT INTO cp.CmGroup (AccountUid, GroupName, GroupDescription, CreatedAt, CreatedBy)
	OUTPUT inserted.GroupId
	VALUES (@AccountUid, @GroupName, @GroupDescription, GETUTCDATE(), @CreatedBy)
	
END

