
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
-- EXEC [ms].[DbDependency_GetLastUpdate] @App='smsapi'
CREATE PROCEDURE [ms].[DbDependency_GetLastUpdate]
	@App varchar(50),
	@Key varchar(50) = NULL
AS
BEGIN
	SELECT a.[Key], ISNULL(k.[LastChangeTime], 0) as LastChangeTime
	FROM ms.TableChangesForApp a
		LEFT OUTER JOIN ms.TableChanges k (NOLOCK) ON k.[Key] = a.[Key]
	WHERE a.App = @App AND (@Key IS NULL OR a.[Key] = @Key)

END
