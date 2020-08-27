
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-04-27
-- Description:	Read Schema
-- =============================================
-- Example
--	EXEC rt.Setting_GetSchema
-- =============================================
CREATE PROCEDURE [rt].[Setting_GetSchema]
	@SchemaId varchar(50) = NULL
AS
BEGIN
	SELECT SchemaId, [Value] FROM rt.Settings WHERE (SchemaId = @SchemaId OR @SchemaId IS NULL)
END
