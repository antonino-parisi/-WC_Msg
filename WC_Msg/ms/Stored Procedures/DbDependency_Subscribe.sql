-- =============================================
-- Author:		Igor Valyansy
-- Create date: 2018-01-18
-- Description:	Simple DB dependancy logic
-- =============================================
-- EXEC [ms].[DbDependency_Subscribe] @App='smscore' @Key='ms.SubAccount'
CREATE PROCEDURE [ms].[DbDependency_Subscribe]
	@App varchar(50),
	@Key varchar(50)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 from ms.TableChangesForApp WHERE [App]=@App AND [Key]=@Key)
      INSERT INTO ms.TableChangesForApp([App],[Key]) VALUES(@App, @Key);
END
