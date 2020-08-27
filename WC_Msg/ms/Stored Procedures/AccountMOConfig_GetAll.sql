

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-07-24
-- Description:	Get MO - SubAccount mapping configuration
-- =============================================
--	EXEC ms.[AccountMOConfig_GetAll]
--	EXEC ms.DbDependency_DataChanged @Key = 'dbo.AccountMODRConfig'
CREATE PROCEDURE [ms].[AccountMOConfig_GetAll]		
AS

	SELECT 
		SubAccountUid, 
		IIF(TPDA_ToMatch = '*', NULL, TPDA_ToMatch) AS Tpda, 
		IIF(Keyword_ToMatch = '*', NULL, Keyword_ToMatch) AS Keyword
	FROM dbo.AccountMODRConfig c
		INNER JOIN dbo.Account a on a.SubAccountId = c.SubAccountId

