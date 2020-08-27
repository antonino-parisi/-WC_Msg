-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2018-20-04
-- =============================================
-- exec cp.Survey_GetSummaryByDates @surveyUid = 92, @SubmittedAtFrom = '2018-10-10', @SubmittedAtTo = '2018-10-20'
CREATE PROCEDURE [cp].[Survey_GetSummaryByDates]
	@SurveyUid INT,
	@SubmittedAtFrom DATETIME = NULL,
	@SubmittedAtTo DATETIME = NULL
AS
BEGIN
	SELECT 
		s.SurveyUid,
		s.SurveyId,
		s.SurveyTitle,
		SUM(MessagesCount) AS MessagesCount, 
		SUM(RejectedCount) AS RejectedCount, 
		SUM(AcceptedCount) AS AcceptedCount,
		SUM(MessageClickedCount) AS MessageClickedCount,  
		CAST(SUM(CAST(TotalClickTimeInSec AS BIGINT)) / IIF(SUM(MessageClickedCount) = 0, 1, SUM(MessageClickedCount)) AS INT) AS AverageClickTimeInSec,
		SUM(ResponseReceivedCount) AS ResponseReceivedCount,  
		CAST(SUM(CAST(TotalResponseReceivedTimeInSec AS BIGINT)) / IIF(SUM(ResponseReceivedCount) = 0, 1, SUM(ResponseReceivedCount)) AS INT) AS AverageResponseReceivedTimeInSec
	FROM
	(
		SELECT 
			SurveyUid, 
			MessagesCount, RejectedCount, AcceptedCount, 
			MessageClickedCount, 
			MessageClickedCount * AverageClickTimeInSec AS TotalClickTimeInSec,
			ResponseReceivedCount, 
			ResponseReceivedCount * AverageResponseReceivedTimeInSec AS TotalResponseReceivedTimeInSec
		FROM sms.SurveyBatch
		WHERE SurveyUid = @SurveyUid 
			AND (@SubmittedAtFrom IS NULL OR (@SubmittedAtFrom IS NOT NULL AND CreatedAt >= @SubmittedAtFrom)) 
			AND (@SubmittedAtTo   IS NULL OR (@SubmittedAtTo   IS NOT NULL AND CreatedAt < @SubmittedAtTo))
	) batches
		INNER JOIN ms.Survey s ON s.SurveyUid = batches.SurveyUid
	GROUP BY s.SurveyUid, s.SurveyId, s.SurveyTitle

END