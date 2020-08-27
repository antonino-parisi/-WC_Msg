-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-08
-- =============================================
CREATE PROCEDURE [cp].[CmSenderIdSuggestion_Add]
	@AccountUid uniqueidentifier,
	@SenderId varchar(16)
AS
BEGIN

	BEGIN TRY

		IF EXISTS (SELECT 1 FROM cp.CmSenderIdSuggestion WHERE AccountUid = @AccountUid AND SenderId = @SenderId)
			UPDATE cp.CmSenderIdSuggestion 
			SET LastUsedAt = SYSUTCDATETIME(), Hits += 1
			WHERE AccountUid = @AccountUid AND SenderId = @SenderId
		ELSE
			INSERT INTO cp.CmSenderIdSuggestion (AccountUid, SenderId, LastUsedAt, Hits)
			VALUES (@AccountUid, @SenderId, SYSUTCDATETIME(), 1)

	END TRY
	BEGIN CATCH
		-- it's not a critical issue
	END CATCH

END
