-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2019-12-11
-- Description:	Get account product info given AccountUid
-- =============================================
-- EXEC map.AccountProductMeta_Get @AccountUid='DBC09EF1-8806-EA11-8158-06B9B96CA965'

CREATE PROCEDURE [map].[AccountProductMeta_Get]
	@AccountUid uniqueidentifier
AS
BEGIN
	SELECT 
		a.AccountUid, 
		a.AccountId, 
		a.AccountName, 
		pm.Product, 
		pm.UsageStartLive,
		pm.UsageStartTest, 
		pm.OnboardingStatus
	FROM cp.Account a
		INNER JOIN ms.AccountProductMeta pm ON a.AccountId = pm.AccountId
	WHERE a.AccountUid = @AccountUid ;

END
