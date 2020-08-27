
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- =============================================
-- EXEC cp.[CmFile_GetManyByAccount] @AccountId='AcmeCorp-0aA4C', @FileCategoryId = 1
CREATE PROCEDURE [cp].[CmFile_GetManyByAccount]
	@AccountId varchar(50) = NULL,			-- one of @AccountId or @AccountUid must be specified
	@AccountUid uniqueidentifier = NULL,
	@Offset int = 0,
	@Limit int = 200,
	@FileCategoryId tinyint
AS
BEGIN
	
	SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)
	
	SELECT FileId, Filename, FileLocation, f.FileTypeId, ft.FileTypeName, f.FileStateId, fs.FileStateName, f.TotalRows, f.ErrorRows, f.DuplicatedRows, f.CreatedAt, f.CreatedBy, u.Login AS CreatedBy_Username
	FROM cp.cmFile f
		LEFT JOIN cp.[User] u ON f.CreatedBy = u.UserId
		LEFT JOIN cp.CmFileState fs ON f.FileStateId = fs.FileStateId
		INNER JOIN cp.CmFileType ft ON f.FileTypeId = ft.FileTypeId
	WHERE f.AccountUid = @AccountUid AND f.DeletedAt IS NULL
		AND ft.FileCategoryId = @FileCategoryId
	ORDER BY f.CreatedAt DESC
	OFFSET (@Offset) ROWS FETCH NEXT (@Limit) ROWS ONLY

END

