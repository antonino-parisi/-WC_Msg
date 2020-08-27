CREATE VIEW map.vwSupplierCostUploaderFileData
AS
	SELECT 
		scufd.*, 
		scuf.FilePath, scuf.CreatedAt, scuf.CreatedBy,
		u.Email AS CreatedBy_Email
	FROM map.SupplierCostUploaderFileData scufd
		INNER JOIN map.SupplierCostUploaderFile scuf ON scufd.FileId = scuf.FileId
		LEFT JOIN map.[User] u ON scuf.CreatedBy = u.UserId
