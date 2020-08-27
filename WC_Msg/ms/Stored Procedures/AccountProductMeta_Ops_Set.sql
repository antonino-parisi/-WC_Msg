
-------------------------
-- Author: Anton
-- Date:   2020-03-09
-- For Ops team
-- EXEC ms.AccountProductMeta_Ops_Set @AccountId = 'abcd', @Product = 'SM', @OnboardingStatus = 'Created', @UsageStartTest = '2020-03-09', @UsageStartLive = NULL
CREATE PROCEDURE [ms].[AccountProductMeta_Ops_Set]
    @AccountId varchar(50),
	@Product char(2),	-- SM / CA / VO / VI
	@OnboardingStatus varchar(10),
	@UsageStartTest date = NULL,
	@UsageStartLive date = NULL
AS
BEGIN
	
	--IF NOT EXISTS (
	--	SELECT 1 
	--	FROM ...)
	--	THROW 51000, 'ERROR: ...', 1;

	UPDATE ms.AccountProductMeta
	SET 
		OnboardingStatus = @OnboardingStatus,
		UsageStartTest = ISNULL(@UsageStartTest, UsageStartTest),
		UsageStartLive = IIF(@UsageStartLive IS NULL AND @OnboardingStatus = 'TRIAL', NULL, ISNULL(@UsageStartLive, UsageStartLive)),
		UpdatedAt = SYSUTCDATETIME()
	WHERE AccountId = @AccountId AND Product = @Product
	
	IF (@@rowcount = 0)
		INSERT INTO ms.AccountProductMeta (AccountId, Product, OnboardingStatus, UsageStartTest, UsageStartLive)
		VALUES (@AccountId, @Product, @OnboardingStatus, @UsageStartTest, @UsageStartLive)
	
	SELECT * 
	FROM ms.AccountProductMeta
	WHERE AccountId = @AccountId AND Product = @Product

END