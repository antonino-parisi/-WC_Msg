
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- =============================================
-- EXEC cp.CmGroup_Delete @AccountId='AcmeCorp-0aA4C', @GroupId=1, @DeletedBy = 'E9BCBF9B-CDC9-4BA6-8C4B-92B41C7F280D'
CREATE PROCEDURE [cp].[CmGroup_Delete]
	@AccountId varchar(50) = NULL,		-- one of @AccountId or @AccountUid must be specified
	@AccountUid uniqueidentifier = NULL, 
	@GroupId int,						
	@DeletedBy uniqueidentifier			-- UserId that deleted record
AS
BEGIN
	
	SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)

	UPDATE cp.CmGroup 
	SET DeletedAt = GETUTCDATE(), DeletedBy = @DeletedBy
	WHERE GroupId = @GroupId AND AccountUid = @AccountUid AND DeletedAt IS NULL

END

