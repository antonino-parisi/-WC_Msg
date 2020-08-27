
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-11-30
-- Description:	Data about SubAccounts MessageSphere 
-- =============================================
-- EXEC ms.SubAccount_GetConfig
-- =============================================
-- OBSOLETE: use [ms].[SubAccount_GetAll] instead of [ms].[SubAccount_GetConfig]
-- =============================================
CREATE PROCEDURE [ms].[SubAccount_GetConfig]
	@Host varchar(10) = NULL
AS
BEGIN

	DECLARE @ClusterGroupId varchar(50)
	SET @ClusterGroupId = ms.ClusterGroup_GetByHost(@Host)

	SELECT sa.SubAccountUid, 
		sa.SubAccountId, 
		sa.AccountId, 
		ISNULL(UPPER(am.CustomerType), 'L') AS CustomerType,
		ISNULL(mtq.MtOutPriority, 10) AS MtOutPriority
	FROM dbo.Account sa
		LEFT JOIN ms.AccountMeta am ON sa.AccountId = am.AccountId
		LEFT JOIN (
			SELECT SubAccountUid, AVG(Priority) AS MtOutPriority
			FROM ms.QueueConfig
			WHERE QueueRole = 'MT' AND SubAccountUid IS NOT NULL 
				AND ClusterGroupId_Consumer IN (@ClusterGroupId, 'ANY')
			GROUP BY SubAccountUid) mtq 
		ON mtq.SubAccountUid = sa.SubAccountUid
	WHERE sa.Active = 1

END
