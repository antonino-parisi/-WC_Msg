-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-02-23
-- =============================================
-- EXEC [cp].[SubAccount_GetAllByAccount] @AccountUid = '000000fe-e2e5-e611-813f-06b9b96ca965'
CREATE PROCEDURE [cp].[SubAccount_GetAllByAccount]
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier = NULL
AS
BEGIN

	DECLARE @ResultT TABLE (SubAccountId varchar(50), [Default] bit, SmsVolume_1M int, UrlShortenerEnabled bit)

	INSERT INTO @ResultT (SubAccountId, [Default], SmsVolume_1M, UrlShortenerEnabled)
	SELECT a.SubAccountId, a.[Default], ISNULL(ss.SmsVolume_1M,0) AS SmsVolume_1M, ISNULL(shrt.IsActive, 0) AS UrlShortenerEnabled
	FROM dbo.Account a
		INNER JOIN cp.Account cpa ON cpa.AccountId = a.AccountId
		LEFT JOIN cp.SubAccountStat ss ON a.SubAccountUid = ss.SubAccountUid
		LEFT JOIN ms.UrlShortenDomainSubAccount shrt ON a.SubAccountUid = shrt.SubAccountUid
	WHERE cpa.AccountUid = @AccountUid AND a.Active = 1 AND a.Deleted = 0

	---- for testing purposes
	--IF @@ROWCOUNT = 0
	--BEGIN
	--	INSERT INTO @ResultT (SubAccountId, [Default], SmsVolume_1M)
	--	SELECT SubAccountId, [Default], ISNULL(ss.SmsVolume_1M,0) AS SmsVolume_1M
	--	FROM dbo.Account a
	--		INNER JOIN cp.Account cpa ON cpa.AccountId = a.AccountId
	--		LEFT JOIN cp.SubAccountStat ss ON a.SubAccountUid = ss.SubAccountUid
	--	WHERE cpa.AccountUid = '619250fe-e2e5-e611-813f-06b9b96ca965' AND a.Active = 1

	--	--INSERT INTO @ResultT (SubAccountId, [Default]) VALUES ('DumpSubaccount', 1)
	--END
	IF NOT EXISTS (SELECT 1 FROM @ResultT WHERE [Default] = 1)
		UPDATE TOP (1) @ResultT SET [Default] = 1 WHERE SubAccountId LIKE '%hq'

	IF NOT EXISTS (SELECT 1 FROM @ResultT WHERE [Default] = 1)
		UPDATE TOP (1) @ResultT SET [Default] = 1

	SELECT SubAccountId, [Default], SmsVolume_1M, UrlShortenerEnabled FROM @ResultT
END
