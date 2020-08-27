---
-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2018-02-12
-- Description:	Load all SessionMessage feature filters.
-- =============================================
CREATE PROCEDURE [ms].[FeatureFilter_SessionMessage_GetAll]
AS
BEGIN

	SELECT SubAccountUid
	FROM ms.FeatureFilter_SessionMessage
	WHERE Enabled = 1
END
