

CREATE VIEW [rpt].[bi_vwStatSmsLog]
AS
	SELECT 
		s.*, 
		c.CountryName
	FROM 
		sms.vwStatSmsLog s
		LEFT JOIN mno.Country c ON s.Country = c.CountryISO2alpha
