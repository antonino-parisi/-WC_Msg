-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-07-13
-- Description:	Local short stat counters
-- =============================================
-- SELECT TOP 1000 * FROM cp.SubAccountStat
CREATE PROCEDURE [cp].[job_VolumeQuickStats_Calculate]
AS
BEGIN

	DECLARE @StartDate1M date = DATEADD(DAY, -30, GETUTCDATE())
	DECLARE @EndDate1M date = GETUTCDATE()
	
	--SELECT SubAccountId, SUM(TotalMessage) as SmsVolume_1M
	--FROM dbo.MessageStats
	--WHERE date >= @StartDate AND MessageType = 'MT'
	--GROUP BY SubAccountId

	MERGE cp.SubAccountStat AS target
    USING (
		
		SELECT 
			sl.SubAccountUid, 
			SUM(sl.SmsCountTotal) as SmsVolume_1M
		FROM sms.StatSmsLogDaily sl (NOLOCK)
		WHERE sl.Date >= @StartDate1M 
			AND sl.Date <= @EndDate1M 
			AND sl.SmsTypeId = 1
		GROUP BY sl.SubAccountUid

	) AS source (SubAccountUid, SmsVolume_1M)
    ON (target.SubAccountUid = source.SubAccountUid)
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (SubAccountUid, SmsVolume_1M) VALUES (source.SubAccountUid, source.SmsVolume_1M)
	WHEN MATCHED THEN
		UPDATE SET SmsVolume_1M = source.SmsVolume_1M
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;
END
