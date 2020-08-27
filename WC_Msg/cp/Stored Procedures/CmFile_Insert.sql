-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- =============================================
-- EXEC cp.[CmFile_Insert] @AccountId='AcmeCorp-0aA4C', @FileTypeId = 10, @FileLocation = 's3://abcdef/upload.csv', @CreatedBy = 'E9BCBF9B-CDC9-4BA6-8C4B-92B41C7F280D'
CREATE PROCEDURE [cp].[CmFile_Insert]
	@AccountId varchar(50) = NULL,		-- one of @AccountId or @AccountUid must be specified
	@AccountUid uniqueidentifier = NULL, 
	@FileId uniqueidentifier = NULL,	-- if NULL then new *sequential* guid will be generated (prefered way)
	@FileTypeId tinyint,
	@FileStateId tinyint = 0,
	@Filename nvarchar(100),
	@FileLocation nvarchar(500),
	@CreatedBy uniqueidentifier			-- UserId that created record
AS
BEGIN
	
	SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)
	
	-- copy-paste because of no other way to set FileId as DEFAULT :(
	IF @FileId IS NULL  
		INSERT INTO cp.cmFile (AccountUid, /*FileId, */Filename, FileLocation, FileTypeId, FileStateId, CreatedAt, CreatedBy)
		OUTPUT inserted.FileId
		VALUES (@AccountUid, /* @FileId, */@Filename, @FileLocation, @FileTypeId, @FileStateId, GETUTCDATE(), @CreatedBy)
	ELSE 
		INSERT INTO cp.cmFile (AccountUid, FileId, Filename, FileLocation, FileTypeId, FileStateId, CreatedAt, CreatedBy)
		OUTPUT inserted.FileId
		VALUES (@AccountUid, @FileId, @Filename, @FileLocation, @FileTypeId, @FileStateId, GETUTCDATE(), @CreatedBy)
END

