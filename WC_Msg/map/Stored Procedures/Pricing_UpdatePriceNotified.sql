-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-04-24
-- Description:	Update time of last price notification for customer
-- =============================================
-- EXEC map.[Pricing_UpdatePriceNotified] @SubAccountUid = 123, @PriceNotifiedAt = '2018-04-24 01:23:45'
-- select top 100 * from rt.CustomerCoverageHistory
CREATE PROCEDURE [map].[Pricing_UpdatePriceNotified]
	@SubAccountUid int,	-- scope of new value
	@PriceNotifiedAt datetime2(2)
AS
BEGIN

	-- v1
	UPDATE sa
	SET PriceNotifiedAt = @PriceNotifiedAt
	FROM dbo.Account sa
	WHERE sa.SubAccountUid = @SubAccountUid AND 
		(sa.PriceNotifiedAt IS NULL OR sa.PriceNotifiedAt < @PriceNotifiedAt)

	-- v2
	UPDATE sa
	SET PriceNotifiedAt = @PriceNotifiedAt
	FROM ms.SubAccount sa
	WHERE sa.SubAccountUid = @SubAccountUid AND 
		(sa.PriceNotifiedAt IS NULL OR sa.PriceNotifiedAt < @PriceNotifiedAt)

	IF @@rowcount = 0 RETURN

	-- capture current prices of SA for future reference
	DECLARE @SubAccountUids varchar(100)
	SELECT @SubAccountUids = CAST(@SubAccountUid as varchar(100)) 

	BEGIN TRY
		INSERT INTO rt.CustomerCoverageHistory (SubAccountUid, PriceNotifiedAt, Country, OperatorId, PriceCurrency, Price)
		SELECT 
			q.SubAccountUid, 
			@PriceNotifiedAt AS PriceNotifiedAt,
			q.Country, 
			q.OperatorId, 
			q.PriceOriginalCurrency, 
			q.PriceOriginal
		FROM rt.fnSMSPricingCoverage(@SubAccountUids, NULL, 1) q
	END TRY
	BEGIN CATCH
		-- do nothing. it might fail in case of multiple requests within same minute
	END CATCH
END
