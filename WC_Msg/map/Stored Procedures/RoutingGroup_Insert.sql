-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-14
-- =============================================
-- EXEC map.RoutingGroup_Insert @UpdatedBy = 123
CREATE PROCEDURE [map].[RoutingGroup_Insert]
	@RoutingGroupName nvarchar(100) = NULL,
	@UpdatedBy smallint
AS
BEGIN

	DECLARE @Output TABLE (RoutingGroupId int)

	INSERT INTO rt.RoutingGroup (RoutingGroupName, DataSourceId, TierLevelCurrent)
	OUTPUT inserted.RoutingGroupId INTO @Output (RoutingGroupId)
	VALUES (@RoutingGroupName, 2 /* Morpheus */, 1)

	SELECT RoutingGroupId FROM @Output
END
