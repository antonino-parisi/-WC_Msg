
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- =============================================
-- EXEC cp.CmGroup_Update @AccountId='AcmeCorp-0aA4C', @GroupId = 1, @GroupName='Group 1-updated'
CREATE PROCEDURE [cp].[CmGroup_Update]
	@AccountId varchar(50) = NULL,		-- one of @AccountId or @AccountUid must be specified
	@AccountUid uniqueidentifier = NULL, 
	@GroupId int,						-- lookup by GroupId
	@GroupName nvarchar(100),			-- new value
	@GroupDescription nvarchar(1000) = NULL	-- new value
AS
BEGIN
	
	SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)

	IF EXISTS (SELECT 1 FROM cp.CmGroup WHERE AccountUid = @AccountUid AND GroupName = @GroupName AND DeletedAt IS NULL AND GroupId <> @GroupId)
		THROW 51000, 'Group with same name already exists', 1;

	UPDATE cp.CmGroup
	SET GroupName = @GroupName, GroupDescription = @GroupDescription
	WHERE GroupId = @GroupId AND AccountUid = @AccountUid AND DeletedAt IS NULL

END

