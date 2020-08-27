
---
-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2018-12-04
-- Description:	Load all AsyncDb feature filters.
-- =============================================
CREATE PROCEDURE [ms].[FeatureFilter_AsyncDb_GetAll]
AS
BEGIN

	SELECT [Priority], SubAccountUid, Enabled
	FROM ms.FeatureFilter_AsyncDb
	ORDER BY [Priority] DESC
END
