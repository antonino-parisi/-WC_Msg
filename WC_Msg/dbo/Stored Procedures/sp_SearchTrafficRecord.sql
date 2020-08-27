-- =============================================
-- Author:		<Author,,Arbie Samong>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- EXEC [dbo].[sp_SearchTrafficRecord] @AccountId = 'Raju1', @SubAccountId = 'Raju1_trial', @Password='raju123', @UMID = '3ea7b9d0-b975-e711-8148-022a22cc1c71'
-- EXEC [dbo].[sp_SearchTrafficRecord] @AccountId = 'appsland', @SubAccountId = 'appsland_std', @Password='Premier1er', @UMID = '5978d4686bc50'
CREATE PROCEDURE [dbo].[sp_SearchTrafficRecord] 
		@AccountId VARCHAR(50),
		@SubAccountId VARCHAR(50),
		@Password VARCHAR(50),
		@UMID VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN
	IF EXISTS (
		SELECT 1
		FROM dbo.AccountCredentials ac
			INNER JOIN dbo.Account a ON ac.AccountId = a.AccountId
		WHERE ac.AccountId = @AccountId
			and ac.Password = @Password COLLATE SQL_Latin1_General_CP1_CS_AS
			and a.SubAccountId = @SubAccountId)

		--SELECT Status, UMID
		--	FROM dbo.TrafficRecord with(nolock) 
		--	WHERE UMID = @UMID AND SubAccountId = @SubAccountId

		SELECT
			dss.StatusOld AS Status,
			CAST(sl.UMID AS VARCHAR(50)) AS UMID
		FROM sms.SmsLog sl WITH (NOLOCK)
			INNER JOIN sms.DimSmsStatus dss WITH (NOLOCK) ON dss.StatusId = sl.StatusId
		WHERE
			(sl.UMID = TRY_CAST(@UMID as uniqueidentifier))


		--UNION
		--	SELECT Status, UMID
		--	FROM dbo.TrafficRecordArchive with(nolock)
		--	WHERE UMID = @UMID and SubAccountId = @SubAccountId
	END	
END