CREATE VIEW sms.vwSenderStats
AS
SELECT AccountId, SubAccountId, Country, OperatorId, ConnId, SenderId_In, SenderId_Out,
        CAST(SUM(Cost_EUR) AS DECIMAL(20,6)) Cost,
        CAST(SUM(Price_EUR) AS DECIMAL(20, 6)) Price,
        SUM(SmsCountTotal) SmsCountTotal, SUM(SmsCountDelivered) SmsCountDelivered,
        SUM(SmsCountUndelivered) SmsCountUndelivered, SUM(SmsCountRejected) SmsCountRejected,
        SUM(MsgCountTotal) MsgCountTotal, SUM(MsgCountDelivered) MsgCountDelivered,
        SUM(MsgCountUndelivered) MsgCountUndelivered, SUM(MsgCountRejected) MsgCountRejected
FROM
    (SELECT smr.AccountId, sms.SubAccountId, sms.Country, sms.OperatorId, sms.ConnId,
        sms.SenderId_In, ISNULL(srp.SenderPoolName, sms.SenderId_Out) SenderId_Out,
        sms.Cost_EUR, sms.Price_EUR, sms.SmsCountTotal, sms.SmsCountDelivered,
        sms.SmsCountUndelivered, sms.SmsCountRejected, sms.MsgCountTotal, sms.MsgCountDelivered,
        sms.MsgCountUndelivered, sms.MsgCountRejected
        FROM
    (SELECT SubAccountId, Country,OperatorId, ConnId,
			ISNULL(SourceOriginal, [Source]) SenderId_In,
			[Source] SenderId_Out,
			SUM(SegmentsReceived * Cost) Cost_EUR,
			SUM(SegmentsReceived * Price) Price_EUR,
			SUM(SegmentsReceived) SmsCountTotal,
			SUM(CASE WHEN StatusId = 40 THEN SegmentsReceived ELSE 0 END) SmsCountDelivered,
			SUM(CASE WHEN StatusId IN (31, 41) THEN SegmentsReceived ELSE 0 END) SmsCountUndelivered,
			SUM(CASE WHEN StatusId = 21 THEN SegmentsReceived ELSE 0 END) SmsCountRejected,
			COUNT(1) MsgCountTotal,
			SUM(CASE WHEN StatusId = 40 THEN 1 ELSE 0 END) MsgCountDelivered,
			SUM(CASE WHEN StatusId IN (31, 41) THEN 1 ELSE 0 END) MsgCountUndelivered,
			SUM(CASE WHEN StatusId = 21 THEN 1 ELSE 0 END) MsgCountRejected
    FROM sms.SmsLog WITH (NOLOCK, INDEX (IX_SmsLog_CreatedTime))
    WHERE 
        CreatedTime >= CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME)
        AND CreatedTime < DATEADD(minute, -10, CAST(GETUTCDATE() AS DATETIME))
    GROUP BY
        SubAccountId, 
        Country, 
        OperatorId,
        ConnId,
        SourceOriginal,
        [Source]
    ) sms
	LEFT JOIN
		(SELECT mr.AccountId, mr.SubAccountId, mr.OperatorId, mr.Country, cc.RouteId,
				mr.OriginalSenderId, mr.NewSenderId, mr.NewSenderPoolId
		FROM optimus.SenderMaskingRules mr
			LEFT JOIN dbo.CarrierConnections cc
				ON ISNULL(mr.RouteId,'') = ISNULL(cc.RouteId,'')
		WHERE mr.NewSenderId IS NULL
			AND mr.NewSenderPoolId IS NOT NULL
		) smr
        ON ISNULL(sms.OperatorId,0) = ISNULL(smr.OperatorId,0)
            AND ISNULL(sms.SubAccountId,0) = ISNULL(smr.SubAccountId,0)
            AND ISNULL(sms.Country,'') = ISNULL(smr.Country,'')
            AND ISNULL(sms.ConnId,'') = ISNULL(smr.RouteId,'')
	LEFT JOIN optimus.SenderRotationPool srp
        ON ISNULL(smr.NewSenderPoolId,0) = srp.SenderPoolId
    ) SMSFinal
GROUP BY AccountId, SubAccountId, Country, OperatorId, ConnId, SenderId_In, SenderId_Out ;
