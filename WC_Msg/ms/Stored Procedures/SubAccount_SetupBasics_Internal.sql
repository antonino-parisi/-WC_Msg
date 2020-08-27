
-- =============================================
-- Change History
-- =============================================
-- Date        Author               Description 
-- ----------  -------------------  ------------------------------------
-- 2020-06-12	Anton Shchekalov	Created
-- =============================================
--	Sample calls
--	EXEC ms.SubAccount_SetupBasics_Internal @SubAccountUid = 123, @Product = 'SM'
-- =============================================
CREATE PROCEDURE [ms].[SubAccount_SetupBasics_Internal]
   @SubAccountUid INT,
   @Product CHAR(2)	-- SM or CA or VO
AS
BEGIN

	IF @SubAccountUid IS NULL OR @SubAccountUid < 1
		THROW 51000, 'Wrong value of SubAccountUid param', 1;

	DECLARE @OnboardingStatus VARCHAR(20) = 'CREATED'

	-- TRIAL status for E & W types
	IF EXISTS (SELECT 1 FROM ms.vwSubAccount (NOLOCK) AS sa WHERE sa.SubAccountUid = @SubAccountUid AND sa.CustomerType IN ('E', 'W'))
		SET @OnboardingStatus = 'TRIAL'

	INSERT INTO ms.AccountProductMeta (AccountId, Product, UsageStartLive, UsageStartTest, OnboardingStatus)
	SELECT sa.AccountId, @Product, NULL, SYSUTCDATETIME(), @OnboardingStatus
	FROM ms.vwSubAccount sa
	WHERE sa.SubAccountUid = @SubAccountUid
		AND NOT EXISTS (SELECT 1 FROM ms.AccountProductMeta AS apm (NOLOCK) WHERE apm.AccountId = sa.AccountId AND apm.Product = @Product)

	-- flag that SA supports SMS since now
	UPDATE ms.SubAccount
	SET 
		Product_SMS = IIF(@Product = 'SM', 1, Product_SMS),
		Product_CA = IIF(@Product = 'CA', 1, Product_CA),
		Product_VO = IIF(@Product = 'VO', 1, Product_VO)
	WHERE SubAccountUid = @SubAccountUid

	UPDATE a 
	SET
		Product_SMS = IIF(@Product = 'SM', 1, a.Product_SMS),
		Product_CA = IIF(@Product = 'CA', 1, a.Product_CA),
		Product_VO = IIF(@Product = 'VO', 1, a.Product_VO)
	FROM ms.SubAccount AS sa
		INNER JOIN cp.Account AS a ON sa.AccountUid = a.AccountUid
	WHERE SubAccountUid = @SubAccountUid

	-- active DR level for both SMS and CA
	IF @Product IN ('SM', 'CA')
	BEGIN
		-- default: DLR level = 4
		INSERT INTO dbo.AccountMTConfig (SubAccountId, DeliveryReportLevel)
		SELECT sa.SubAccountId, 8 /* DLR 4th level */
		FROM ms.SubAccount sa
		WHERE sa.SubAccountUid = @SubAccountUid
			AND NOT EXISTS (SELECT 1 FROM dbo.AccountMTConfig am WHERE am.SubAccountId = sa.SubAccountId)  	
    END

END
