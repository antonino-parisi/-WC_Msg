
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-08
-- =============================================
CREATE PROCEDURE [cp].[CmSenderIdSuggestion_Save]
	@AccountUid uniqueidentifier,
	@SenderId varchar(16)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM cp.CmSenderIdSuggestion WHERE AccountUid = @AccountUid AND SenderId = @SenderId)
		UPDATE cp.CmSenderIdSuggestion 
		SET LastUsedAt = GETUTCDATE()
		WHERE AccountUid = @AccountUid AND SenderId = @SenderId
	ELSE
		INSERT INTO cp.CmSenderIdSuggestion (AccountUid, SenderId, LastUsedAt)
		VALUES (@AccountUid, @SenderId, GETUTCDATE())

END

