CREATE VIEW [rt].[vwSupplierConn_Uptime]
AS	
	-- Seconds in day: 24 * 60 * 60 = 86400
	-- Seconds in week: 24 * 60 * 60 * 7 = 604800
	-- Seconds in month: 24 * 60 * 60 * 30 = 2592000

	SELECT 
		sc.ConnUid,
		sc.ConnId,
		sc.IsConnected,
		CAST(CASE
			WHEN sc.UptimeLast1dSum + DATEDIFF(SECOND, sc.UpdatedAt, SYSUTCDATETIME()) * IIF(sc.IsConnected = 1, 1, -1) < 0 THEN 0
			WHEN sc.UptimeLast1dSum + DATEDIFF(SECOND, sc.UpdatedAt, SYSUTCDATETIME()) * IIF(sc.IsConnected = 1, 1, -1) > 86400 THEN 1
			ELSE (sc.UptimeLast1dSum + DATEDIFF(SECOND, sc.UpdatedAt, SYSUTCDATETIME()) * IIF(sc.IsConnected = 1, 1, -1)) / CAST(86400 AS decimal(11,1))
		END AS DECIMAL(5,4)) UptimeLast1d,
		CAST(CASE
			WHEN sc.UptimeLast7dSum + DATEDIFF(SECOND, sc.UpdatedAt, SYSUTCDATETIME()) * IIF(sc.IsConnected = 1, 1, -1) < 0 THEN 0
			WHEN sc.UptimeLast7dSum + DATEDIFF(SECOND, sc.UpdatedAt, SYSUTCDATETIME()) * IIF(sc.IsConnected = 1, 1, -1) > 604800 THEN 1
			ELSE (sc.UptimeLast7dSum + DATEDIFF(SECOND, sc.UpdatedAt, SYSUTCDATETIME()) * IIF(sc.IsConnected = 1, 1, -1)) / CAST(604800 AS decimal(11,1))
		END AS DECIMAL(5,4)) UptimeLast7d,   
		CAST(CASE
			WHEN sc.UptimeLast30dSum + DATEDIFF(SECOND, sc.UpdatedAt, SYSUTCDATETIME()) * IIF(sc.IsConnected = 1, 1, -1) < 0 THEN 0
			WHEN sc.UptimeLast30dSum + DATEDIFF(SECOND, sc.UpdatedAt, SYSUTCDATETIME()) * IIF(sc.IsConnected = 1, 1, -1) > 2592000 THEN 1
			ELSE (sc.UptimeLast30dSum + DATEDIFF(SECOND, sc.UpdatedAt, SYSUTCDATETIME()) * IIF(sc.IsConnected = 1, 1, -1)) / CAST(2592000 AS decimal(11,1))
		END AS DECIMAL(5,4)) UptimeLast30d
	FROM rt.SupplierConn AS sc 
	WHERE sc.Deleted = 0
