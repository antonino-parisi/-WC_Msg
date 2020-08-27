-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-05-16
-- details in task https://app.asana.com/0/109711080795570/465594247684463
-- =============================================
-- EXEC optimus.job_ChinaUnicom_DeactivateBadSenderIds
CREATE PROC optimus.job_ChinaUnicom_DeactivateBadSenderIds
AS
BEGIN
	
	DECLARE @SenderIdToBlock TABLE (
		OperatorId int,
		ConnUid int,
		SenderId varchar(16)
	);
	--SELECT Source INTO @SenderIdToBlock (SenderId)

	WITH q AS (
		SELECT ConnUid, OperatorId, Source, 
			--ISNULL([40],0) AS QtyDelivered, ISNULL([41],0) AS QtyBlocked,
			ISNULL([40],0) + ISNULL([41],0) AS QtyTotal,
			100 * ISNULL([40],0) / NULLIF(ISNULL([40],0) + ISNULL([41],0), 0) AS DeliveryRate
		FROM (
			SELECT ConnUid, OperatorId, Source, StatusId, COUNT(1) AS Qty
			FROM sms.SmsLog (NOLOCK)
			WHERE CreatedTime BETWEEN DATEADD(DAY, -1, SYSUTCDATETIME()) AND SYSUTCDATETIME()
				AND SmsTypeId = 1
				AND Country = 'CN' AND ConnUid IN (48, 49) /* ChinaUnicom & ChinaUnicom_HQ */ 
				AND StatusId IN (40, 41) /* DELIVERED TO DEVICE & REJECTED BY DEVICE */
			GROUP BY ConnUid, OperatorId, Source, StatusId
		) AS SourceTable 
		PIVOT ( SUM(Qty) FOR StatusId IN ([40], [41]) ) AS OutputTable
	)

	INSERT INTO @SenderIdToBlock (OperatorId, ConnUid, SenderId)
	SELECT q.OperatorId, q.ConnUid, q.Source
	--SELECT * FROM q;
	FROM q
	WHERE	(QtyTotal BETWEEN 6 AND 10 AND DeliveryRate < 60)
		OR	(QtyTotal BETWEEN 11 AND 20 AND DeliveryRate < 65)
		OR	(QtyTotal > 20 AND DeliveryRate < 70)
		--OR	(QtyTotal < 6 AND DeliveryRate < 80)

	-- remove SenderId from pool rotation for X days
	UPDATE p SET NextAvailabilityTimeUtc = DATEADD(MONTH, 1, GETUTCDATE())
	--SELECT TOP 100 *
	FROM optimus.SenderMaskingRules r
		INNER JOIN rt.SupplierConn c ON r.RouteId = c.ConnId
		INNER JOIN optimus.SenderRotationPoolList p ON r.NewSenderPoolId = p.SenderPoolId
		INNER JOIN @SenderIdToBlock b ON p.SenderId = b.SenderId AND b.OperatorId = r.OperatorId AND b.ConnUid = c.ConnUid
	WHERE r.NewSenderPoolId IS NOT NULL AND r.Country = 'CN'

END
