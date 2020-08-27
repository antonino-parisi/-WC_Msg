-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE PROCEDURE optimus.[DbDependency_CacheCleared]
	@Key varchar(50)
AS
BEGIN
    UPDATE ms.TableChanges SET ToClearCache = 0 WHERE [Key] = @Key
END
