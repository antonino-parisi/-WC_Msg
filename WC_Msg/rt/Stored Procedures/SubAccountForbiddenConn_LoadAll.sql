-- =============================================
-- Author:		Alex Saunin
-- Create date: 2017-10-17
-- =============================================
-- EXEC rt.SubAccountForbiddenConn_LoadAll @LastSyncTimestamp = '2017-08-01'
CREATE PROCEDURE [rt].[SubAccountForbiddenConn_LoadAll]
	@LastSyncTimestamp datetime = NULL
AS
BEGIN
	SELECT 
	    safc.SubAccoutUid, 
	    safc.ConnUid, 
	    safc.Deleted
	FROM rt.SubAccountForbiddenConn safc
	WHERE ((@LastSyncTimestamp IS NULL AND safc.Deleted = 0) 
		OR (@LastSyncTimestamp IS NOT NULL AND safc.UpdatedAt >= @LastSyncTimestamp))
END
