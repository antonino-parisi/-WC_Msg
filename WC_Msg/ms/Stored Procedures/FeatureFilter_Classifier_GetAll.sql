-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-01-11
-- Description:	Classifier feature filters. Loaded by WS.MessageSphere.Core configuration
-- =============================================
CREATE PROCEDURE [ms].[FeatureFilter_Classifier_GetAll]
AS
BEGIN

	SELECT 
		c.[Priority], 
		c.CustomerType, 
		c.Country, 
		c.SubAccountUid, 
		c.IsActive,
	    c.Version
	FROM ms.FeatureFilter_Classifier c
	ORDER BY c.[Priority] DESC
END
