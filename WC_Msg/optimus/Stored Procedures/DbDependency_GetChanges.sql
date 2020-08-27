-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
--	EXEC [optimus].[DbDependency_GetChanges]
CREATE PROCEDURE [optimus].[DbDependency_GetChanges]
	@OnlyChanged bit = 1,
	@App varchar(50) = 'optimus'
AS
BEGIN
	
	--DECLARE @App varchar(50) = 'optimus'

    SELECT k.[Key], k.ToClearCache
	FROM ms.TableChangesForApp a
		LEFT OUTER JOIN ms.TableChanges k (NOLOCK) ON k.[Key] = a.[Key]
	WHERE a.App = 'optimus'
		--(@Key IS NULL OR [Key] = @Key) 
		AND (@OnlyChanged = 0 OR ToClearCache = 1)
		--AND 1 = 0 /* bye-bye Optimus v1 */
END
