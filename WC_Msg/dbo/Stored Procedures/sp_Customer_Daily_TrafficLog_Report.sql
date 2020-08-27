
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 25-02-2016
-- Description:	Get sms log data for feature "send email with daily sms log attachment"
-- Example: EXEC [dbo].[sp_Customer_Daily_TrafficLog_Report] 'Tokopedia1', 0
-- =============================================
CREATE PROCEDURE [dbo].[sp_Customer_Daily_TrafficLog_Report]
			@AccountId nvarchar(50), @UpdateEmailLastSentTime bit = 0
AS

	-- We return data with 1 hour delay because nearest messages can still be in proccess of delivering
	DECLARE @EndDate datetime
	SET @EndDate = DATEADD(hh, -1, GETUTCDATE())
	
	-- Limiting output records just in case it will be too much results. And we don't want to create load on [TrafficRecord] table
	SELECT TOP (10000) tr.UMID, tr.[SubAccountId], o.Country, tr.Destination, tr.Source, tr. DateTimeStamp, tr.Status,
		CASE asl.IncludeBody WHEN 1 THEN tr.Body ELSE NULL END as Body
    FROM dbo.[AccountSMSLogReports] asl
		INNER JOIN dbo.Account a ON asl.AccountId = a.AccountId
		INNER JOIN [dbo].[TrafficRecord] tr (NOLOCK) ON a.SubAccountId = tr.SubAccountId
		LEFT JOIN dbo.Operator o ON tr.OperatorId = o.OperatorId
	WHERE tr.DateTimeStamp BETWEEN asl.EmailLastSentTime and @EndDate
		AND asl.AccountId = @AccountId and tr.Status <> 'PART OF A MESSAGE'
	
	IF @UpdateEmailLastSentTime = 1
	BEGIN
		UPDATE dbo.[AccountSMSLogReports]
		SET EmailLastSentTime = @EndDate
		WHERE AccountId=@AccountId
	END
