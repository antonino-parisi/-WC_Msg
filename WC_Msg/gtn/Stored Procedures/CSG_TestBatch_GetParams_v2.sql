
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-06-02
-- Description:	List of all TestCases
-- =============================================
-- Examples:
-- EXEC gtn.CSG_TestBatch_GetParams_v2 @OperatorId = 250001, @RouteId = 'RouteSMS_Cambo', @TestCase = 'SMS MT Alphanumeric'
-- =============================================
CREATE PROCEDURE [gtn].[CSG_TestBatch_GetParams_v2]
	@OperatorId int,
	@RouteId varchar(50),
	@TestCase varchar(50)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT TOP (1) tn.TestNodeUID, CSG_SMSRouteID as SMSRouteID, tc.SMSTemplateID, tc.SMSTemplateName, tc.InterpretationRulesJson
	FROM gtn.CSG_TestNode tn
		CROSS JOIN gtn.CSG_Route r
		CROSS JOIN gtn.CSG_TestCase tc
	WHERE tn.OperatorId = @OperatorId
		AND r.WC_RouteId = @RouteId
		AND tc.TestCase = @TestCase
END

