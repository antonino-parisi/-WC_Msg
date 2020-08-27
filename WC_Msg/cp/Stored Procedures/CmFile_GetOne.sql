
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- =============================================
-- EXEC cp.[CmFile_GetOne] @AccountId='AcmeCorp-0aA4C', @FileId = '8EDA7679-F8E6-E611-813F-06B9B96CA965'
CREATE PROCEDURE [cp].[CmFile_GetOne]
	@AccountId varchar(50) = NULL,			-- one of @AccountId or @AccountUid must be specified
	@AccountUid uniqueidentifier = NULL,
	@FileId uniqueidentifier
AS
BEGIN
	
	SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)
	
	SELECT FileId, Filename, FileLocation, f.FileTypeId, ft.FileTypeName, f.FileStateId, fs.FileStateName, f.TotalRows, f.ErrorRows, f.DuplicatedRows, f.CreatedAt, f.CreatedBy, u.Login AS CreatedBy_Username
	FROM cp.cmFile f
		LEFT JOIN cp.[User] u ON f.CreatedBy = u.UserId
		LEFT JOIN cp.CmFileState fs ON f.FileStateId = fs.FileStateId
		LEFT JOIN cp.CmFileType ft ON f.FileTypeId = ft.FileTypeId
	WHERE f.AccountUid = @AccountUid AND f.DeletedAt IS NULL AND f.FileId = @FileId
	
END

