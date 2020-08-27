
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-08
-- =============================================
CREATE PROCEDURE [cp].[CmSenderIdSuggestion_GetAll]
	@AccountUid uniqueidentifier
AS
BEGIN
	SELECT TOP (30) SenderId
	FROM cp.CmSenderIdSuggestion
	WHERE AccountUid = @AccountUid
	ORDER BY LastUsedAt DESC
END

