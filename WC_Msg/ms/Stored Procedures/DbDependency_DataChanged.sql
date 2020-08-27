


-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE PROCEDURE [ms].[DbDependency_DataChanged]
	@Key varchar(50)
AS
BEGIN
	SET NOCOUNT ON

    UPDATE ms.TableChanges 
	SET LastChangeTime = GETUTCDATE(), ToClearCache = 1
	WHERE [Key] = @Key

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO ms.TableChanges ([Key], LastChangeTime, ToClearCache)
		VALUES (@Key, GETUTCDATE(), 1)
	END
END


