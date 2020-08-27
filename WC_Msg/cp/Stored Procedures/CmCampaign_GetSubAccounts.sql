-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-02-23
-- =============================================
CREATE PROCEDURE [cp].[CmCampaign_GetSubAccounts]
	@AccountUid uniqueidentifier
AS
BEGIN

	DECLARE @ResultT TABLE (SubAccountId varchar(50), [Default] bit)

	INSERT INTO @ResultT (SubAccountId, [Default])
	SELECT SubAccountId, [Default]
	FROM dbo.Account a
		INNER JOIN cp.Account cpa ON cpa.AccountId = a.AccountId
	WHERE cpa.AccountUid = @AccountUid AND a.Active = 1

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO @ResultT (SubAccountId, [Default]) VALUES ('DumpSubaccount', 1)
	END

	SELECT SubAccountId, [Default] FROM @ResultT
END

