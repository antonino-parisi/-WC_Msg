
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-07-20
-- Description:	MNOLookup feature filters. Loaded by WS.MessageSphere.Core configuration
-- =============================================
CREATE PROCEDURE [ms].[FeatureFilter_MNOLookup_GetAll]
AS
BEGIN

	SELECT 
		FilterId, 
		[Priority], 
		Country, 
		SubAccountId, 
		IsActive, 
		ApiVersion,
		FallbackEnabled
	FROM ms.FeatureFilter_MNOLookup
	ORDER BY [Priority] DESC
END