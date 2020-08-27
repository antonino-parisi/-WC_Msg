-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-05-15
-- Description:	Reset account balance alert
-- =============================================
CREATE PROCEDURE [ms].[AccountBalanceAlert_Reset]
	@AccountUid uniqueidentifier,
	@ResetFirstBalanceAlert bit = 0,
	@ResetBalanceZeroAlert bit = 0,
	@ResetFirstOverdraftAlert bit = 0,
	@ResetOverdraftZeroAlert bit = 0
AS
BEGIN
	DECLARE @AccountId varchar(50);
	SELECT @AccountId = AccountId FROM cp.Account WHERE AccountUid = @AccountUid;
	UPDATE dbo.AccountBalanceAlert
	SET IsFirstBalanceAlerted = IIF(@ResetFirstBalanceAlert = 1, 1, IsFirstBalanceAlerted),
		IsBalanceZeroAlerted = IIF(@ResetBalanceZeroAlert = 1, 1, IsBalanceZeroAlerted),
		IsFirstOverdraftalerted = IIF(@ResetFirstOverdraftAlert = 1, 1, IsFirstOverdraftalerted),
		IsOverdraftZeroalerted = IIF(@ResetOverdraftZeroAlert = 1, 1, IsOverdraftZeroalerted)
	WHERE AccountId = @AccountId
END