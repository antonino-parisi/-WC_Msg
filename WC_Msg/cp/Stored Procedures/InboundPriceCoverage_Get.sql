---
-- =============================================
-- History:
-- 2020-03-12	Anton Shchekalov	Created
-- =============================================
-- select top 100 * from rt.vwInboundPriceCoverage c left join cp.[User] u on u.AccountUId = c.AccountUId
-- EXEC cp.InboundPriceCoverage_Get @AccountUid = 'E923F695-189D-E711-8141-06B9B96CA965', @UserUid = 'ACF688C7-6E65-4B14-A660-88429E4FCD1E', @SubAccountUid = 18378, @VNType = 'T', @VNCountry = 'SG'
CREATE PROCEDURE [cp].[InboundPriceCoverage_Get]
	@AccountUid uniqueidentifier,
	@UserUid uniqueidentifier,
	@SubAccountUid int,
	@VNType char(1),
	@VNCountry char(2)
AS
BEGIN

	IF NOT EXISTS (
		SELECT 1 
		FROM cp.fnSubAccount_GetByUser (@AccountUid, @UserUid, @SubAccountUid, 1, NULL, NULL, NULL)
	)
	BEGIN
		PRINT 'no access found'
		RETURN
	END

	-- debug 
	--DECLARE @SubAccountUid int = 18378
	--DECLARE @VNType char(1) = 'T'
	--DECLARE @VNCountry char(2) = 'SG'

	DECLARE @PricingIn TABLE (
		Country char(2) NULL, 
		OperatorId int NULL, 
		Currency char(3) NOT NULL,
		PricePerSms decimal(18,6) NOT NULL
	)

	--DECLARE @PricingOut TABLE (
	--	Country char(2) NOT NULL, 
	--	OperatorId int NOT NULL, 
	--	Currency char(3) NOT NULL,
	--	PricePerSms decimal(18,6) NOT NULL,
	--	RuleSrc VARCHAR(10) NOT NULL,
	--	RulePriority TINYINT NOT NULL,
	--	RowNum TINYINT NOT NULL,
	--	UNIQUE (Country, OperatorId, RulePriority)
	--)
	--INSERT INTO 
	--EXEC cp.VirtualNumberRental_Get @AccountUid = @AccountUid, @UserUid = @UserUid, @VnRentalId = @VnRentalId

	INSERT INTO @PricingIn (Country, OperatorId, Currency, PricePerSms)
	SELECT 
		ISNULL(p.MSISDNCountry, @VNCountry) AS MSISDNCountry, 
		p.MSISDNOperatorId, 
		p.Currency, 
		p.PricePerSms
	FROM rt.InboundPriceCoverage p
	WHERE
		p.BillingStart <= SYSUTCDATETIME()
		AND p.BillingEnd >= SYSUTCDATETIME()
		AND p.SubaccountUid = @SubAccountUid
		AND p.VNType = @VNType
		AND p.VNCountry = @VNCountry
		AND ISNULL(p.MSISDNCountry, @VNCountry) = @VNCountry

	--select * from @PricingIn

	SELECT 
		q.Country, 
		c.CountryName,
		q.OperatorId,
		o.OperatorName,
		q.Currency, 
		q.PricePerSms
		--q.RuleSrc, q.RulePriority, q.RowNum
	FROM (
		SELECT 
			*,
			ROW_NUMBER () OVER (PARTITION BY Country, OperatorId ORDER BY RulePriority) as RowNum
		FROM (
			SELECT 
				p.Country, 
				p.OperatorId, 
				p.Currency, 
				p.PricePerSms,
				'O' AS RuleSrc,
				1 AS RulePriority
			FROM @PricingIn p
			WHERE p.Country IS NOT NULL AND p.OperatorId IS NOT NULL

			UNION 
			SELECT 
				p.Country, 
				o.OperatorId, 
				p.Currency, 
				p.PricePerSms,
				'C' AS RuleSrc,
				2 AS RulePriority
			FROM @PricingIn p
				INNER JOIN mno.Operator o ON p.Country = o.CountryISO2alpha
			WHERE p.Country IS NOT NULL AND p.OperatorId IS NULL
		) q2
	) q
		LEFT JOIN mno.Country c ON q.Country = c.CountryISO2alpha
		LEFT JOIN mno.Operator o ON q.OperatorId = o.OperatorId
END
