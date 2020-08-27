

-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-08
-- =============================================
CREATE PROCEDURE [cp].[CmSenderIdBlacklist_GetAll]
	@AccountUid uniqueidentifier
AS
BEGIN
	SELECT SenderIdPattern, SenderIdPatternFlag
	FROM cp.CmSenderIdBlacklistGlobal
END
