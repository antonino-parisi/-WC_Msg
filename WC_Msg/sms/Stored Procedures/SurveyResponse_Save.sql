-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-01-24
-- Description:	User response on Survey  - insert or update existing by UMID
-- =============================================
-- EXEC sms.SurveyResponse_Save @UMID='ECFAB7DF-B501-E811-814B-020897DF5459', @StartedAt = '2018-01-28 09:55:27.68', @FinishedAt = '2018-01-28 09:58:27.68', @ResponseJson = '{example:1}'
CREATE PROCEDURE [sms].[SurveyResponse_Save]
	@UMID uniqueidentifier,
	@StartedAt datetime2(2),
	@FinishedAt datetime2(2),
	@ResponseJson nvarchar(3000),
	@FillTime int	-- [deprecated] duration of filling survey form
WITH EXECUTE AS 'dbo'
AS
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM sms.SurveyResponse WHERE UMID = @UMID)
	BEGIN
		DECLARE @FirstClickAt datetime2(2)
		SELECT TOP (1) @FirstClickAt = FirstAccessedAt FROM sms.UrlShorten (NOLOCK) WHERE UMID = @UMID

		INSERT INTO sms.SurveyResponse (UMID, StartedAt, FinishedAt, ResponseJson, FillTime)
		VALUES (@UMID, ISNULL(@FirstClickAt, @StartedAt), @FinishedAt, @ResponseJson, ISNULL(@FillTime, 0))

		--SET @FillTime = DATEDIFF(SECOND, @StartedAt, @FinishedAt)
		--EXEC sms.SurveyResponse_UpdateCampaignStats @UMID = @UMID, @FillTimeInSec = @FillTime
		EXEC sms.SurveyResponse_UpdateSurveyStats @UMID = @UMID, @SurveyFinishedAt = @FinishedAt
	END
	ELSE
	BEGIN
		UPDATE sms.SurveyResponse
		SET FinishedAt = @FinishedAt, ResponseJson = @ResponseJson, @FillTime = ISNULL(@FillTime, 0)
		WHERE UMID = @UMID
	END

END
