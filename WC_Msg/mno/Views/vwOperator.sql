
CREATE VIEW [mno].[vwOperator]
AS
	SELECT OperatorId, CountryISO2alpha CountryCode, OperatorName, Active
	FROM mno.Operator;

