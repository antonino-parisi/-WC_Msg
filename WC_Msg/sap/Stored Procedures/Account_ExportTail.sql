-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-06-06
-- =============================================
-- SAMPLE:
-- EXEC sap.Account_ExportTail @LastChangedSince = '2020-01-01', @AccountEntity = 'WSG'
CREATE PROCEDURE [sap].[Account_ExportTail]
	@LastChangedSince date,
	@AccountEntity varchar(10) = NULL
AS
BEGIN
	SELECT
		cp.AccountUid,
		cp.AccountId,
		cp.CompanyName,
		CAST(cp.CreatedAt AS date) AS CreatedAt,
		UPPER(am.BillingMode) AS BillingMode,
		UPPER(am.CustomerType) AS CustomerType,
		am.CompanyEntity as AccountEntity,
		am.Manager as Manager,
		CAST(cp.UpdatedAt as smalldatetime) AS UpdatedAt,
		cp.InvoiceEmails AS E_Mail,
		am.Currency
	FROM cp.Account cp
		LEFT JOIN ms.AccountMeta am ON am.AccountId = cp.AccountId
		--INNER JOIN (
		--	SELECT DISTINCT AccountUid
		--	FROM sms.StatSmsLogDaily s
		--	WHERE s.Date >= DATEADD(MONTH, -3, SYSDATETIME())
		--) st
	WHERE cp.Deleted = 0 
		AND cp.UpdatedAt >= @LastChangedSince
		AND (@AccountEntity IS NULL OR (@AccountEntity IS NOT NULL AND am.CompanyEntity = @AccountEntity))
		AND am.CustomerType NOT IN ('L', 'I')
		--AND am.EntityCountryISO IN ('SG', 'ID')
		-- test stage
		--AND cp.AccountId IN ('TATA','eatigo','Redmart','Bukalapak1','berrypay','elpia','lazada_ph','acommerce_Parent','acommerce','acommerceID','acommercePH','acommerceTH','acommerceOTP','Promotexter','garena','Tokopedia1')
	
END
