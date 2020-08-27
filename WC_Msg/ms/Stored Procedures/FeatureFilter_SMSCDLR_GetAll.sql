
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-07-20
-- Description:	SMSCDLR feature filters. Loaded by WS.MessageSphere.Core configuration
-- =============================================
CREATE PROCEDURE [ms].[FeatureFilter_SMSCDLR_GetAll]
AS
BEGIN
	SELECT FilterId, [Priority], RouteId, ISNULL(s.OperatorId, o.OperatorId) as OperatorId, SubAccountId, IsActive
	FROM ms.FeatureFilter_SMSCDLR s
		LEFT JOIN mno.Operator o ON s.OperatorId IS NULL and o.CountryISO2alpha = s.CountryISO2alpha
	ORDER BY [Priority] DESC
END
