-------------------------
-- Author: Anton
-- Date:   2020-01-09
-- For Ops team
-- EXEC ms.SubAccount_Ops_SetAsset @SubAccountId = 'abcd', @SF_SMS_Usage_ProductCode = 'VOSVC0221-01', @SF_SMS_Usage_AssetId = 'insert real asset'
CREATE PROCEDURE ms.SubAccount_Ops_SetAsset
    @SubAccountId varchar(50),
	@SF_SMS_Usage_ProductCode varchar(20),
	@SF_SMS_Usage_AssetId varchar(255)
AS
BEGIN
	
	IF NOT EXISTS (
		SELECT 1 
		FROM ms.DimSFProductCode 
		WHERE ProductCode = @SF_SMS_Usage_ProductCode)
		THROW 51000, 'ERROR: Such SF_SMS_Usage_ProductCode does not exist or registered yet', 1;  

	UPDATE ms.SubAccount
	SET 
		SF_SMS_Usage_ProductCode = @SF_SMS_Usage_ProductCode,
		SF_SMS_Usage_AssetId = @SF_SMS_Usage_AssetId
	WHERE SubAccountId = @SubAccountId
	
	RETURN @@rowcount
END


GRANT EXECUTE ON ms.SubAccount_Ops_SetAsset to role_team_ops_l1