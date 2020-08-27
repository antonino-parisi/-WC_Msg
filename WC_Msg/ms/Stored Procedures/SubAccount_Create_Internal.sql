-- =============================================
-- Change History
-- =============================================
-- Date        Author               Description 
-- ----------  -------------------  ------------------------------------
-- 2020-06-12	Anton Shchekalov	Created
-- =============================================
--	Sample calls
--	EXEC ms.SubAccount_Create_Internal @AccountUid = 'xxx', @SubAccountId = 'blabla_hq'
-- =============================================
CREATE PROCEDURE [ms].[SubAccount_Create_Internal]
   @AccountUid UNIQUEIDENTIFIER,
   @SubAccountId VARCHAR(50),
   @Description varchar(1000) = NULL
AS
BEGIN

	DECLARE @SubAccountUid INT = NULL
	
	-- return existing record if exists
	SELECT @SubAccountUid = SubAccountUid FROM ms.SubAccount WHERE SubAccountId = @SubAccountId AND AccountUid = @AccountUid
	IF 	@SubAccountUid IS NOT NULL
	BEGIN
		PRINT 'SubAccountId = ' + @SubAccountId + ' already exists'
		RETURN @SubAccountUid
	END
	
	IF EXISTS (SELECT 1 FROM ms.SubAccount AS sa WHERE sa.SubAccountId = @SubAccountId)
		THROW 51000, 'SubAccountId already exists and belongs to another Account', 1;

	DECLARE @AccountId VARCHAR(50)
	SELECT @AccountId = AccountId FROM cp.Account (NOLOCK) WHERE AccountUid = @AccountUid

	INSERT INTO dbo.Account
			(AccountId, SubAccountId, [Description], TrafficRecording, Active, [Default], [Date], 
			StandardRouteId, PricingFormula, IsBalanceOrOverdraftAlert)
	VALUES
		(@AccountId, @SubAccountId, ISNULL(@Description, 'High Quality channel'), 1, 1, 1, SYSUTCDATETIME(), 
		'', '',  1)

	SELECT @SubAccountUid = SCOPE_IDENTITY() ;
	--SELECT @SubAccountUid = SubAccountUid FROM dbo.Account WHERE SubAccountId = @SubAccountId 
	
	INSERT INTO ms.SubAccount
		(SubAccountUid, SubAccountId, AccountUid, Active, 
		CreatedAt, PriceNotifiedAt, Product_SMS, Product_CA, Product_VO)
	VALUES
		(@SubAccountUid, @SubAccountId, @AccountUid, 1, SYSUTCDATETIME(), NULL, 0, 0, 0)

	RETURN @SubAccountUid;
END
