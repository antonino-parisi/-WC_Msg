




-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2019-10-28
-- Description:	ChatApps pricing for selected subaccount.
--	it's just version 0.1. More data structure changes to come to support more levels of rule inheritances
-- =============================================
-- SELECT * FROM ms.SubAccount sa INNER JOIN cp.[User] u ON u.AccountUid = sa.AccountUid WHERE sa.Product_CA = 1 AND u.UserStatus = 'A'
-- EXEC cp.[ChatApps_Pricing_GetList] @AccountUid = '85E3F8CC-59A4-E711-8144-02D85F55FCE7', @UserId = 'B88E67B9-415B-4473-A534-C078DDE4E1BE', @SubAccountUid = 26893, @ChannelUid = NULL
-- EXEC cp.[ChatApps_Pricing_GetList] @AccountUid = '2318BDEB-C250-E711-8141-06B9B96CA965', @UserId = '76C9B0B7-77C3-4248-8877-0A8295638BE3', @SubAccountUid = 18369, @ChannelUid = 5
CREATE PROCEDURE [cp].[ChatApps_Pricing_GetList]
	@AccountUid uniqueidentifier,
    @UserId uniqueidentifier,
	@SubAccountUid int,
	@ChannelUid tinyint = NULL
	--@Country char(2) = NULL,			-- optional filter
	--@SubAccountIds varchar(1000) = NULL	-- optional filter, comma-separated list
--WITH EXECUTE AS OWNER
AS
BEGIN
	
	EXEC cp.User_CheckPermissions @AccountUid = @AccountUid, @UserId = @UserId, @SubAccountUid = @SubAccountUid

	-- get pricing
	DECLARE @PricingPlanId smallint = 19 /* Default Plan - 'USD Standard' TODO: move from code to some settings table */

	---- overwrite default Pricing Plan, if exists
	SELECT @PricingPlanId = PricingPlanId 
	FROM ipm.PricingPlanSubAccount ps
	WHERE ps.SubAccountUid = @SubAccountUid 
		AND PeriodStart <= GETUTCDATE()
		AND PeriodEnd > GETUTCDATE()

	-- read Currency of account
	DECLARE @ContractCurrency char(3) = 'EUR' /* Default currency - TODO: move from code to some settings table */
	SELECT @ContractCurrency = Currency 
	FROM ms.AccountMeta am INNER JOIN cp.Account a ON am.AccountId = a.AccountId 
	WHERE a.AccountUid = @AccountUid

	-- get final pricing
	SELECT pvt.Country, c.CountryName, @ContractCurrency AS Currency, [WA-HSM], [VB-OUT-TXT], [VB-OUT-MEDIA]
	FROM 
		mno.Country c LEFT JOIN
		(
			SELECT 
				--ppc.CoverageId,
				c.ChannelType + '-' + ppc.ContentTypeCode AS ContentType,
				ppc.Country,
				--ppc.Currency,
				mno.CurrencyConverter(ppc.Price, ppc.Currency, @ContractCurrency, DEFAULT) AS Price
			FROM ipm.PricingPlanCoverage ppc
				INNER JOIN ipm.ChannelType c ON ppc.ChannelTypeId = c.ChannelTypeId
			WHERE ppc.PricingPlanId = @PricingPlanId
				AND (@ChannelUid IS NULL OR (@ChannelUid IS NOT NULL AND ppc.ChannelTypeId = @ChannelUid))
				AND ppc.PeriodStart <= GETUTCDATE()
				AND ppc.PeriodEnd > GETUTCDATE()
		) p	PIVOT (AVG (Price) FOR ContentType IN ([WA-HSM], [VB-OUT-TXT], [VB-OUT-MEDIA])) as pvt
			ON pvt.Country = c.CountryISO2alpha
	WHERE ([WA-HSM] IS NOT NULL OR [VB-OUT-TXT] IS NOT NULL)
	ORDER BY pvt.Country
END
