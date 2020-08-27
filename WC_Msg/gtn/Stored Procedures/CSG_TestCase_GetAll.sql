
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-06-02
-- Description:	List of all TestCases
-- =============================================
-- Examples:
-- EXEC gtn.[CSG_TestCase_GetAll] @OperatorId = 250001, @RouteId = 'RouteSMS_Cambo'
-- =============================================
CREATE PROCEDURE [gtn].[CSG_TestCase_GetAll]
	@OperatorId int,
	@RouteId varchar(50)
AS
BEGIN

	-- Exit if testing for requested destination is unsupported
	IF NOT EXISTS(SELECT 1 FROM gtn.CSG_Route WHERE WC_RouteId = @RouteId) RETURN
	IF NOT EXISTS(SELECT 1 FROM gtn.CSG_TestNode WHERE OperatorId = @OperatorId) RETURN

	-- Return test cases
	SELECT tc.TestCase
	FROM gtn.CSG_TestCase tc
	ORDER BY 1
END

