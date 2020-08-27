
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-27
-- Description:	UrlShorten - get black listed words
-- =============================================
CREATE PROCEDURE [ms].[UrlShortenBlacklist_GetAll]
AS
BEGIN	
	SELECT token as Token
	FROM [ms].[UrlShortenBlacklist]
END
