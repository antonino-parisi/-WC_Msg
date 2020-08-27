

CREATE VIEW [ms].[vwFeatureFilter_Optimus]
AS
	SELECT o.*, c.ConnId
	FROM [ms].FeatureFilter_Optimus o
		LEFT JOIN rt.SupplierConn c on o.RouteUid = c.ConnUid
