-- =============================================
-- Author: Tony Ivanov
-- Create date: 2020-08-05
-- Description:	Redact API feature filters. Loaded by WS.MessageSphere.Core configuration
-- =============================================
CREATE PROCEDURE [ms].[FeatureFilter_RedactApi_GetAll]
AS
BEGIN
    SELECT
        FilterId,
        [Priority],
        AccountUid,
        IsActive
    FROM ms.FeatureFilter_RedactApi
    ORDER BY [Priority] DESC
END
