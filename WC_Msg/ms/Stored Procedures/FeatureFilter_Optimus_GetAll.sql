---
-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2018-09-18
-- Description:	Load all Optimus features
-- =============================================
-- EXEC ms.DbDependency_DataChanged @Key = 'ms.FeatureFilter_Optimus'
CREATE PROCEDURE [ms].[FeatureFilter_Optimus_GetAll]
AS
BEGIN

	--DECLARE @Host varchar(20) = UPPER(HOST_NAME())
	--SET @Host = 'PRO-SMS2'

	SELECT
		opt.Priority,
		opt.Country,
		opt.RouteUid,
		cc.RouteId,
		opt.ApiVersion
		--IIF(@Host = 'PRO-SMS3', 'V2', opt.ApiVersion) AS ApiVersion
	FROM ms.FeatureFilter_Optimus opt
		LEFT JOIN dbo.CarrierConnections cc ON opt.RouteUid = cc.RouteUid
	WHERE opt.IsActive = 1
		
END