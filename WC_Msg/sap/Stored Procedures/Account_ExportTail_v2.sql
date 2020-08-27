-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-06-06
-- =============================================
-- SAMPLE:
-- EXEC sap.Account_ExportTail_v2 @LastChangedSince = '2016-01-01', @CompanyEntity = 'SG'
CREATE PROCEDURE [sap].[Account_ExportTail_v2]
	@LastChangedSince date,
	@CompanyEntity varchar(10) = NULL
AS
BEGIN
	SELECT
		cp.AccountUid,
		cp.AccountId,
		cp.CompanyName,
		CAST(cp.CreatedAt AS date) AS CreatedAt,
		UPPER(am.BillingMode) AS BillingMode,
		UPPER(am.CustomerType) AS CustomerType,
		am.CompanyEntity,
		mng.Name as Manager,
		CAST(cp.UpdatedAt as smalldatetime) AS UpdatedAt,
		cp.InvoiceEmails AS E_Mail,
		am.Currency,
		am.SalesforceCustomerId
	FROM cp.Account cp
		LEFT JOIN ms.AccountMeta am ON am.AccountId = cp.AccountId
		LEFT JOIN ms.AccountManager mng WITH (NOLOCK) ON am.ManagerId = mng.ManagerId
	WHERE cp.Deleted = 0 
		AND cp.UpdatedAt >= @LastChangedSince
		AND (@CompanyEntity IS NULL OR (@CompanyEntity IS NOT NULL AND am.CompanyEntity = @CompanyEntity))
		AND am.CustomerType NOT IN ('L', 'I')
		--AND am.CompanyEntity IN ('SG', 'ID')
		-- test stage
		--AND cp.AccountId IN ('TATA','eatigo','Redmart','Bukalapak1','berrypay','elpia','lazada_ph','acommerce_Parent','acommerce','acommerceID','acommercePH','acommerceTH','acommerceOTP','Promotexter','garena','Tokopedia1')
	
END
