-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-05-09
-- =============================================
--EXECUTE map.SupplierCostUploaderFile_Insert @ConnUid = 15, @FilePath = '/sampleurl/test.csv', @ItemsSaved = 12, @ItemsError = 1, @CreatedBy = 45
CREATE PROCEDURE [map].[SupplierCostUploaderFile_Insert]
	@FilePath varchar(500),
	@CreatedBy smallint
AS
BEGIN

	INSERT INTO map.SupplierCostUploaderFile 
		(FilePath, ItemsSaved, ItemsError, CreatedAt, CreatedBy)
	OUTPUT inserted.FileId
	VALUES (@FilePath, 0, 0, SYSUTCDATETIME(), @CreatedBy)

END
