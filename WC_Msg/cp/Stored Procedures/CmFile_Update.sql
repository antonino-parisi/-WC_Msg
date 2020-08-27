-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- =============================================
-- EXEC cp.[CmFile_Update] @AccountId='AcmeCorp-0aA4C', @FileId = '8DDA7679-F8E6-E611-813F-06B9B96CA965', @FileStateId = 5
CREATE PROCEDURE [cp].[CmFile_Update]
	@AccountId varchar(50) = NULL,		-- one of @AccountId or @AccountUid must be specified
	@AccountUid uniqueidentifier = NULL, 
	@FileId uniqueidentifier,
	@FileStateId tinyint,
	@TotalRows int = NULL,	-- if pass NULL value, column will not be updated
	@ErrorRows int = NULL,	-- if pass NULL value, column will not be updated
	@DuplicatedRows int = NULL
AS
BEGIN
	
	SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)
	
	UPDATE cp.cmFile
	SET FileStateId = @FileStateId, 
		TotalRows = ISNULL(@TotalRows, TotalRows), 
		ErrorRows = ISNULL(@ErrorRows, ErrorRows),
		DuplicatedRows = ISNULL(@DuplicatedRows, DuplicatedRows)
	WHERE AccountUid = @AccountUid AND FileId = @FileId

END

