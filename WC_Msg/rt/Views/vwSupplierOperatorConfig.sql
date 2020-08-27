CREATE VIEW rt.vwSupplierOperatorConfig
AS
	SELECT cfg.*, sc.ConnId, o.CountryISO2alpha AS Country, o.OperatorName, dss.Status AS DRExpirationStatus, cfg.DRExpirationInMin / 60 AS DRExpirationInHours
	FROM rt.SupplierOperatorConfig cfg
		LEFT JOIN rt.SupplierConn AS sc ON cfg.ConnUid = sc.ConnUid
		LEFT JOIN mno.Operator AS o ON cfg.OperatorId = o.OperatorId
		LEFT JOIN sms.DimSmsStatus AS dss ON cfg.DRExpirationStatusId = dss.StatusId
