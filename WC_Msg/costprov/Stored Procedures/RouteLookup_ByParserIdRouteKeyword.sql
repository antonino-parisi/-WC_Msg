
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-06-10
-- Description:	CostProvisioning process / Detect RouteId from supplier's email
-- =============================================
CREATE PROCEDURE costprov.RouteLookup_ByParserIdRouteKeyword (
	@ParserId varchar(50),
	@RouteKeyword varchar(50)
)
AS
BEGIN
	SELECT RouteId FROM costprov.RouteLookup WHERE ParserId = @ParserId AND RouteKeyword = @RouteKeyword
END

