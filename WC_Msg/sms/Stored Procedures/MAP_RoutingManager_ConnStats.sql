
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-31
-- =============================================
-- EXEC sms.MAP_RoutingManager_ConnStats @Country = 'SG', @OperatorId = 525001
CREATE PROCEDURE [sms].[MAP_RoutingManager_ConnStats]
	@Country char(2),
	@OperatorId int -- NULL means undefined operator
AS
BEGIN

	--DECLARE @Country char(2) = 'SG', @OperatorId int = 525001

	SELECT s1w.ConnUid, s1w.ConnId, 
		s1w.SmsCountAccepted_1W, s1w.DeliveryRate_1W,
		ISNULL(s1d.SmsCountAccepted, 0) AS SmsCountAccepted_1D, ISNULL(s1d.DeliveryRate, 0) AS DeliveryRate_1D,
		ISNULL(s1h.SmsCountAccepted, 0) AS SmsCountAccepted_1H, ISNULL(s1h.DeliveryRate, 0) AS DeliveryRate_1H
	FROM (
		SELECT s1w.ConnUid, s1w.ConnId, 
			SUM(s1w.SmsCountAccepted) AS SmsCountAccepted_1W,
			IIF(SUM(s1w.SmsCountAccepted) > 0, CAST((CAST(SUM(s1w.SmsCountDelivered) * 100 AS decimal(18,4)) / SUM(s1w.SmsCountAccepted)) AS decimal(6,2)), 0) AS DeliveryRate_1W
		FROM sms.vwStatSmsLogDaily s1w
		WHERE s1w.Country = @Country AND ISNULL(s1w.OperatorId, 0) = ISNULL(@OperatorId, 0)
			AND s1w.Date >= DATEADD(DAY, -8, SYSUTCDATETIME())
		GROUP BY s1w.ConnUid, s1w.ConnId
	) s1w
	LEFT JOIN (
		SELECT ConnUid, ConnId, 
			SUM(SmsCountAccepted) AS SmsCountAccepted,
			IIF(SUM(SmsCountAccepted) > 0, CAST((CAST(SUM(SmsCountDelivered) * 100 AS decimal(18,4)) / SUM(SmsCountAccepted)) AS decimal(6,2)), 0) AS DeliveryRate
		FROM sms.vwStatSmsLog s1d
		WHERE s1d.Country = @Country AND ISNULL(s1d.OperatorId, 0) = ISNULL(@OperatorId, 0)
			AND s1d.TimeFrom >= DATEADD(HOUR, -24, SYSUTCDATETIME())
		GROUP BY s1d.ConnUid, s1d.ConnId 
	) s1d ON s1w.ConnUid = s1d.ConnUid
	LEFT JOIN (
		SELECT ConnUid, ConnId, 
			SUM(SmsCountAccepted) AS SmsCountAccepted,
			IIF(SUM(SmsCountAccepted) > 0, CAST((CAST(SUM(SmsCountDelivered) * 100 AS decimal(18,4)) / SUM(SmsCountAccepted)) AS decimal(6,2)), 0) AS DeliveryRate
		FROM sms.vwStatSmsLog s1h
		WHERE Country = @Country AND ISNULL(OperatorId, 0) = ISNULL(@OperatorId, 0)
			AND TimeFrom >= DATEADD(MINUTE, -75, SYSUTCDATETIME())
		GROUP BY ConnUid, ConnId 
	) s1h ON s1w.ConnUid = s1h.ConnUid
END
