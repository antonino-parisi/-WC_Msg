-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-10
-- =============================================
-- EXEC cp.UiNews_GetMany @Limit = 10
CREATE PROCEDURE [cp].[UiNews_GetMany]
	@Limit smallint = 10
AS
BEGIN
	
	SELECT TOP (@Limit) n.NewsId, n.Title, n.Message, n.Url, n.UrlText, n.NewsDate
	FROM cp.UiNews n
	ORDER BY n.NewsDate DESC
END
