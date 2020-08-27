-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-07-20
-- Description:	SmsRouter feature filters. Loaded by WS.MessageSphere.Core configuration
-- =============================================
CREATE PROCEDURE [ms].[FeatureFilter_SmsRouter_GetAll]
AS
BEGIN
	SELECT 
		f.FilterId, 
		f.[Priority], 
		f.SubAccountId,
		sa.SubAccountUid,
		f.Country, 
		f.OperatorId, 
		f.IsActive
	FROM ms.FeatureFilter_SmsRouter f
		LEFT JOIN ms.SubAccount AS sa ON f.SubAccountId = sa.SubAccountId
	ORDER BY f.[Priority] DESC
END
