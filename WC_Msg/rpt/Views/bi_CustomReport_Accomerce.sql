
CREATE VIEW [rpt].[bi_CustomReport_Accomerce]
AS
	SELECT AccountId, SubAccountId, CAST(CreatedTime AS date) as SentDate, ClientMessageId, Status, SUM(SegmentsReceived) AS SmsVolume, SUM(SegmentsReceived * Price) AS Price, PriceCurrency
	FROM [sms].vwSmsLog (NOLOCK)
	WHERE AccountId IN ('acommerce', 'acommerceID', 'acommerceMY', 'acommercePH', 'acommerceSG', 'acommerceTH', 'acommerceVN')
		AND Status_Final = 1
		AND CreatedTime >= '2017-05-26'
	GROUP BY AccountId, SubAccountId, CAST(CreatedTime AS date), ClientMessageId, Status, PriceCurrency
	--ORDER BY 1, 2, 3, 4, 5
