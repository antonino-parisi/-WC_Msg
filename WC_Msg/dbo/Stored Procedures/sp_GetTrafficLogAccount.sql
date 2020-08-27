
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 25-02-2016
-- Description:	Get accounts with a feature of sending them email with daily sms log attachment
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetTrafficLogAccount]	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT DISTINCT asl.AccountId, asl.ScheduleTimes, IncludeBody
		--hotfix at 2016-05-04. will be removed at next deploy
		--CASE asl.IncludeBody WHEN 1 THEN '1' ELSE '0' END AS IncludeBody
	FROM dbo.Account a
		INNER JOIN dbo.[AccountSMSLogReports] asl ON a.AccountId = asl.AccountId
	WHERE a.Active=1
END
