CREATE VIEW [rpt].[bi_Operator]
AS
	select * from operator LEFT OUTER JOIN [mno].[Country] on Operator.Country=[mno].[Country].countryname
