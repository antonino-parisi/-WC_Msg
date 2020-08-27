
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-09-14
-- =============================================
CREATE PROCEDURE [cp].[CmSenderIdSuggestion_Remove]
	@AccountUid uniqueidentifier,
	@SenderId varchar(16)
AS
BEGIN
	DELETE FROM cp.CmSenderIdSuggestion WHERE AccountUid = @AccountUid AND SenderId = @SenderId
END
