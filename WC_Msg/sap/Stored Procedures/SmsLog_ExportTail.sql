-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-06-06
-- =============================================
-- SAMPLE:
-- EXEC sap.SmsLog_ExportTail @LastChangedSince = '2020-01-01', @AccountEntity = 'WSG'
CREATE PROCEDURE [sap].[SmsLog_ExportTail]
	@LastChangedSince date,
	@AccountEntity varchar(10) = NULL
--WITH EXECUTE AS OWNER 
AS
BEGIN

	--DECLARE @LastChangedSince date = '2018-06-04'

	SELECT
		s.StatEntryId,
		s.[Date],
		s.AccountUid,
		a.AccountId,
		s.SubAccountUid,
		a.SubAccountId,
		s.Country,
		c.CountryName,
		s.OperatorId,
		ISNULL(o.OperatorName, 'Others') AS OperatorName,
		s.ConnUid,
		sc.ConnId,
		UPPER(am.BillingMode) AS BillingMode,
		UPPER(am.CustomerType) AS CustomerType,
		am.Manager as Manager,	
		am.CompanyEntity as AccountEntity,
		cm.CompanyEntity as SupplierEntity,
		s.SmsCountAccepted,
		s.Price,
		s.Cost,
		s.Margin,
		--ISNULL(s.PriceContractCurrency, 'EUR') AS PriceContractCurrency,
		--IIF(s.PriceContractCurrency IS NOT NULL, s.PriceContract, s.Price) AS PriceContract,
		ISNULL(NULLIF(am.Currency, ''), 'EUR') AS PriceContractCurrency,
		IIF(s.PriceContractCurrency = am.Currency, 
			s.PriceContract, 
			IIF(s.PriceContractCurrency IS NOT NULL, 
				mno.CurrencyConverter(s.PriceContract, s.PriceContractCurrency, ISNULL(NULLIF(am.Currency, ''), 'EUR'), s.Date),
				mno.CurrencyConverter(s.Price, 'EUR', ISNULL(NULLIF(am.Currency, ''), 'EUR'), s.Date))
		) AS PriceContract,

		--ISNULL(s.CostContractCurrency, 'EUR')  AS CostContractCurrency,
		--IIF(s.CostContract IS NOT NULL, s.CostContract, s.Cost) AS CostContract
		ISNULL(NULLIF(cm.Currency, ''), 'EUR') AS CostContractCurrency,
		IIF(s.CostContractCurrency = cm.Currency, 
			s.CostContract, 
			IIF(s.CostContractCurrency IS NOT NULL, 
				mno.CurrencyConverter(s.CostContract, s.CostContractCurrency, ISNULL(NULLIF(cm.Currency, ''), 'EUR'), s.Date),
				mno.CurrencyConverter(s.Cost, 'EUR', ISNULL(NULLIF(cm.Currency, ''), 'EUR'), s.Date))
		) AS CostContract

	FROM (
		SELECT 
			StatEntryId,
			[Date], 
			AccountUid,
			SubAccountUid, 
			Country, 
			OperatorId, 
			ConnUid,
			SmsCountTotal - SmsCountRejected	AS SmsCountAccepted,
			CAST(Price as decimal(30,6))		AS Price,
			CAST(Cost as decimal(30,6))			AS Cost,
			CAST(Price - Cost as decimal(30,6))	AS Margin,
			PriceContractCurrency,
			PriceContract,
			CostContractCurrency,
			CostContract
		FROM sms.StatSmsLogDaily WITH (NOLOCK)
		WHERE 
			--Date >= DATEADD(MONTH, -2, GETUTCDATE())	-- limit to 2 last months
			Date >= @LastChangedSince
			AND Date < CAST(GETUTCDATE() AS date) -- exclude today
			--AND Date < '2019-03-01'		-- test stage
			--AND Date >= '2019-02-01'	-- test stage
			--AND LastUpdatedAt >= @LastChangedSince
			AND [Date] < DATEADD(dd, 1, EOMONTH(@LastChangedSince))
			AND SmsCountTotal - SmsCountRejected > 0	-- remove zero values
			--AND (ISNULL(Cost, 0) <> 0 AND ISNULL(Price, 0) <> 0 AND ISNULL(CostContract, 0) <> 0 AND ISNULL(PriceContract, 0) <> 0)
			AND (ISNULL(PriceContract, 0) <> 0 AND ISNULL(CostContract, 0) <> 0) 
			-- debug stage
			--AND SubAccountUid IN (
			--	SELECT SubAccountUid 
			--	FROM dbo.Account WITH (NOLOCK)
			--	WHERE CustomerType <> 'I'
				--WHERE AccountId IN ('TATA','eatigo','Redmart','Bukalapak1','berrypay','elpia','lazada_ph','acommerce_Parent','acommerce','acommerceID','acommercePH','acommerceTH','acommerceOTP','Promotexter','garena','Tokopedia1', 'egenticas', 'egenticasMY','kredivo','happyfresh','otogroup','PALAWAN_Pawnshop')
			--) 
		--GROUP BY Date, AccountUid, SubAccountUid, Country, OperatorId, ConnUid
		--HAVING SUM(SmsCountTotal - SmsCountRejected) > 0
		) s
		LEFT JOIN dbo.Account a WITH (NOLOCK) ON s.SubAccountUid = a.SubAccountUid
		LEFT JOIN ms.AccountMeta am WITH (NOLOCK) ON am.AccountId = a.AccountId
		LEFT JOIN rt.SupplierConn sc WITH (NOLOCK) ON sc.ConnUid = s.ConnUid
		LEFT JOIN ms.CarrierMeta cm WITH (NOLOCK) ON sc.ConnId = cm.RouteId
		LEFT JOIN mno.Country c WITH (NOLOCK) ON s.Country = c.CountryISO2alpha
		LEFT JOIN mno.Operator o WITH (NOLOCK) ON s.OperatorId = o.OperatorId
	WHERE 
		sc.ConnId <> 'TrashMessage'
		AND (@AccountEntity IS NULL OR (@AccountEntity IS NOT NULL AND am.CompanyEntity = @AccountEntity))
		--AND am.EntityCountryISO IN ('SG', 'ID')
		AND am.CustomerType <> 'I'
		AND a.AccountId NOT IN ('8x8inc', 'Agreeculture_3iID9')

	ORDER BY 
		a.AccountId, s.SmsCountAccepted DESC
END
