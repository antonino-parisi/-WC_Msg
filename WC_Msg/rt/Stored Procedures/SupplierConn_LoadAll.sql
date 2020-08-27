-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-25
-- =============================================
-- EXEC rt.SupplierConn_LoadAll @LastSyncTimestamp = '2017/08/29'
CREATE PROCEDURE [rt].[SupplierConn_LoadAll]
	@LastSyncTimestamp datetime = NULL
WITH EXECUTE AS 'dbo'
AS
BEGIN
	--DECLARE @LastSyncTimestamp datetime = '2017/10/02 10:00'
	SELECT cc.RouteUid AS ConnUid, cc.RouteId AS ConnId, 
		1-cc.Active AS Deleted, 
		ISNULL(sc.IsConnected, 0) AS IsConnected--,
--		0 AS isProhibited
	FROM dbo.CarrierConnections cc
		LEFT JOIN rt.SupplierConn sc ON cc.RouteUid = sc.ConnUid
	WHERE ((@LastSyncTimestamp IS NULL AND cc.Active = 1) 
		OR (@LastSyncTimestamp IS NOT NULL AND (cc.UpdatedAt >= @LastSyncTimestamp OR sc.UpdatedAt >= @LastSyncTimestamp)))
END
