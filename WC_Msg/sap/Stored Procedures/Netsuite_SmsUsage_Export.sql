-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2019-06-06
-- =============================================
-- SAMPLE:
-- EXEC sap.Netsuite_SmsUsage_Export @Month = '2020-06-01', @CompanyEntity = '8x8UK'
CREATE PROCEDURE [sap].[Netsuite_SmsUsage_Export]
	@Month date,
	@CompanyEntity varchar(10)
AS
BEGIN

	--DECLARE @LastChangedSince date = '2018-06-04'

	SELECT
		--YEAR(s.EOMDate) AS Year,
		--MONTH(s.EOMDate) AS Month, 
		s.EOMDate,
		s.AccountUid,
		a.AccountId,
		UPPER(am.BillingMode) AS BillingMode,
		UPPER(apm.OnboardingStatus) AS OnboardingStatus,
		am.SalesforceCustomerId AS SF_CustomerId,
		sa.SF_SMS_Usage_ProductCode,
		sa.SF_SMS_Usage_AssetId,
		am.CompanyEntity,
		SUM(s.SmsCountAccepted) AS SmsVolume,
		--ISNULL(s.PriceContractCurrency, 'EUR') AS PriceContractCurrency,
		--IIF(s.PriceContractCurrency IS NOT NULL, s.PriceContract, s.Price) AS PriceContract,
		ISNULL(am.Currency, 'EUR') AS PriceContractCurrency,
		SUM(IIF(s.PriceContractCurrency = am.Currency, 
			s.PriceContract, 
			mno.CurrencyConverter(s.PriceContract, s.PriceContractCurrency, ISNULL(am.Currency, 'EUR'), s.EOMDate)
		)) AS PriceContract

	FROM (
		SELECT 
			EOMONTH(Date) AS EOMDate,
			AccountUid,
			SubAccountUid, 
			SUM(SmsCountTotal - SmsCountRejected) AS SmsCountAccepted,
			PriceContractCurrency,
			SUM(PriceContract) AS PriceContract
		FROM sms.StatSmsLogDaily WITH (NOLOCK)
		WHERE 
			--Date >= DATEADD(MONTH, -2, GETUTCDATE())	-- limit to 2 last months
			Date >= DATEADD(DAY, 1, EOMONTH(@Month,-1))
			AND Date < DATEADD(DAY, 1, EOMONTH(@Month))
			--AND Date < CAST(GETUTCDATE() AS date) -- exclude today
			--AND LastUpdatedAt >= @LastChangedSince
			-- ConnId <> 'TrashMessage'
			AND SmsCountTotal - SmsCountRejected > 0	-- remove zero values
			AND (ISNULL(Cost, 0) <> 0 AND ISNULL(Price, 0) <> 0 AND ISNULL(CostContract, 0) <> 0 AND ISNULL(PriceContract, 0) <> 0)
			---- debug stage
			--AND SubAccountUid IN (
			--	SELECT SubAccountUid 
			--	FROM ms.SubAccount WITH (NOLOCK)
			--	--WHERE CustomerType NOT IN ('I')
			--	--WHERE AccountId IN ('TATA','eatigo','Redmart','Bukalapak1','berrypay','elpia','lazada_ph','acommerce_Parent','acommerce','acommerceID','acommercePH','acommerceTH','acommerceOTP','Promotexter','garena','Tokopedia1', 'egenticas', 'egenticasMY','kredivo','happyfresh','otogroup','PALAWAN_Pawnshop')
			--) 
		GROUP BY 
			EOMONTH([Date]),
			--YEAR([Date]), MONTH([Date]), 
			AccountUid, SubAccountUid, PriceContractCurrency
		--HAVING SUM(SmsCountTotal - SmsCountRejected) > 0
		) s
		LEFT JOIN ms.SubAccount sa WITH (NOLOCK) ON s.SubAccountUid = sa.SubAccountUid
		LEFT JOIN cp.Account a WITH (NOLOCK) ON sa.AccountUid = a.AccountUid
		LEFT JOIN ms.AccountMeta am WITH (NOLOCK) ON am.AccountId = a.AccountId
		LEFT JOIN ms.AccountProductMeta AS apm WITH (NOLOCK) ON am.AccountId = apm.AccountId AND apm.Product = 'SM'
	WHERE 
		(@CompanyEntity IS NULL OR (@CompanyEntity IS NOT NULL AND am.CompanyEntity = @CompanyEntity))
		AND am.CustomerType <> 'I'
		AND am.BillingMode = 'POSTPAID'
		
	GROUP BY
		s.EOMDate,
		s.AccountUid,
		a.AccountId,
		am.BillingMode,
		apm.OnboardingStatus,
		am.SalesforceCustomerId,
		sa.SF_SMS_Usage_ProductCode,
		sa.SF_SMS_Usage_AssetId,
		am.CompanyEntity,
		am.Currency
	ORDER BY 
		s.AccountUid
END
