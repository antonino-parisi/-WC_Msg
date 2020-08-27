
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-11-03
-- Description:	List of all Test Route mapping
-- =============================================
-- Examples:
-- EXEC [gtn].[CSG_TestRoute_Update] .....
-- =============================================
CREATE PROCEDURE [gtn].[CSG_TestRoute_Update]
	@CSG_SMSRouteId VARCHAR(50),
	@WC_RouteId VARCHAR(50)
AS
BEGIN

	IF EXISTS (SELECT 1 FROM gtn.CSG_Route WHERE CSG_SMSRouteId = @CSG_SMSRouteId)
	BEGIN
		UPDATE gtn.CSG_Route SET WC_RouteId = @WC_RouteId WHERE CSG_SMSRouteId = @CSG_SMSRouteId
	END
	ELSE
	BEGIN
		DELETE FROM gtn.CSG_Route WHERE WC_RouteId = @WC_RouteId
		INSERT INTO gtn.CSG_Route (CSG_SMSRouteId, WC_RouteId) VALUES (@CSG_SMSRouteId, @WC_RouteId)
	END
END

