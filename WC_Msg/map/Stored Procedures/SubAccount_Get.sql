-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2019-12-17
-- Description:	Get SubAccount
-- =============================================
-- EXEC map.SubAccount_Get @SubAccountId='Advocado_test'
CREATE PROCEDURE [map].[SubAccount_Get]
	@SubAccountId varchar(50)
AS
BEGIN
	SELECT 
		ms.SubAccountUid, 
		ms.SubAccountId, 
		ms.AccountUid, 
		a.AccountId, 
		ms.Active, 
		ms.PriceNotifiedAt,
		ms.Product_SMS, 
		ms.Product_CA, 
		ms.Product_VO, 
		ms.SF_SMS_Usage_ProductCode, 
		ms.SF_SMS_Usage_AssetId,
		ms.CreatedAt, 
		ms.UpdatedAt
	FROM ms.SubAccount ms
		INNER JOIN cp.Account a ON ms.AccountUid = a.AccountUid
	WHERE ms.SubAccountId = @SubAccountId

END
