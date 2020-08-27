-- =============================================
-- Author:		Rebecca
-- Create date: 2019-07-31
-- =============================================
CREATE FUNCTION [rt].[fnGetSubAccountPrice] (
	@SubAccountUid int,
	@Country char(2)
)
RETURNS TABLE  
AS  
RETURN  
	SELECT SubAccountUid, Country, OperatorId, IIF(PriceOriginal IS NULL, PriceCurrency, PriceOriginalCurrency) Currency,
			ISNULL(PriceOriginal, Price) Price
	FROM rt.CustomerGroupCoverage WITH (NOLOCK)
	WHERE SubAccountUid = @SubAccountUid
		AND Country = @Country
		AND Deleted = 0
		AND OperatorId IS NOT NULL
	UNION
	SELECT SubAccountUid, Country, o.OperatorId, IIF(PriceOriginal IS NULL, PriceCurrency, PriceOriginalCurrency) Currency,
			ISNULL(PriceOriginal, Price) Price
	FROM rt.CustomerGroupCoverage c WITH (NOLOCK),
		(SELECT OperatorId
		FROM mno.Operator WITH (NOLOCK)
		WHERE CountryISO2Alpha = @Country
		EXCEPT
		SELECT OperatorId
		FROM rt.CustomerGroupCoverage WITH (NOLOCK)
		WHERE SubAccountUid = @SubAccountUid
			AND Country = @Country
			AND Deleted = 0
			AND OperatorId IS NOT NULL
		) o
	WHERE c.SubAccountUid = @SubAccountUid
		AND c.Country = @Country
		AND Deleted = 0
		AND c.OperatorId IS NULL ;
