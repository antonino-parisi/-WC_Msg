-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-08
-- =============================================
CREATE PROCEDURE [cp].[CmSenderId_GetBlacklist]
	@AccountUid uniqueidentifier
AS
BEGIN
	SELECT SenderIdPattern, SenderIdPatternFlag
	FROM cp.CmSenderIdBlacklistGlobal
END
