
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-05-09
-- =============================================
-- EXEC map.SupplierCostUploaderFile_GetAll @Limit = 10
CREATE PROCEDURE [map].[SupplierCostUploaderFile_GetAll]
	@Offset int = 0,		-- pagination
	@Limit int = 200		-- pagination
AS
BEGIN

	--DECLARE @Offset int = 0
	--DECLARE @Limit int = 10

	SELECT
		f.FileId, 
		f.FilePath, 
		f.CreatedAt, f.CreatedBy, 
		u.FirstName + ' ' + u.LastName AS CreatedBy_User,
		q.ConnUid, cc.ConnId, 
		q.ItemsSaved, q.ItemsError	
	FROM (
			SELECT FileId, ConnUid, 
				SUM(IIF(Saved = 1, 1, 0)) AS ItemsSaved, 
				SUM(IIF(IsValid = 0, 1, 0)) AS ItemsError
			FROM map.SupplierCostUploaderFileData
			GROUP BY FileId, ConnUid
			ORDER BY FileId DESC, ConnUid 
			OFFSET (@Offset) ROWS FETCH NEXT (@Limit) ROWS ONLY
		) q
		INNER JOIN map.SupplierCostUploaderFile f ON f.FileId = q.FileId
		LEFT JOIN map.[User] u ON f.CreatedBy = u.UserId
		LEFT JOIN rt.SupplierConn cc ON cc.ConnUid = q.ConnUid

	/*
	WITH q AS (
		SELECT
			f.FileId, 
			--f.ConnUid, cc.ConnId, 
			f.FilePath, 
			--f.ItemsSaved, f.ItemsError,
			f.CreatedAt, f.CreatedBy, 
			u.FirstName + ' ' + u.LastName AS CreatedBy_User 
		FROM map.SupplierCostUploaderFile f
			LEFT JOIN map.[User] u ON f.CreatedBy = u.UserId
			--LEFT JOIN rt.SupplierConn cc ON cc.ConnUid = f.ConnUid
		ORDER BY f.FileId DESC
		OFFSET (@Offset) ROWS FETCH NEXT (@Limit) ROWS ONLY
	)
	SELECT q.FileId, q.FilePath, q.CreatedAt, q.CreatedBy, q.CreatedBy_User,
		ISNULL(d.ItemsSaved, 0) AS ItemsSaved, 
		ISNULL(d.ItemsError, 0) AS ItemsError,
		cc.ConnUid, cc.ConnId
	FROM q
		LEFT JOIN (
			SELECT FileId, ConnUid, 
				COUNT(Saved) AS ItemsSaved, 
				SUM(IIF(IsValid = 0, 1, 0)) AS ItemsError
			FROM map.SupplierCostUploaderFileData
			GROUP BY FileId, ConnUid
		) d ON q.FileId = d.FileId
		LEFT JOIN rt.SupplierConn cc ON cc.ConnUid = d.ConnUid
		*/
	-- Note: I prefer not to calculate and return TotalRows. To make it lighter 
	--	UI can always show next page. If this page will return 0 records, treat it as last page
	--  (Anton)
END
