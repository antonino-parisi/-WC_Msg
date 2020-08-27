
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-22
-- Shows list of CPv2 accounts and users by keyword in MAP app.
-- =============================================
-- EXEC [map].CPUser_FindByKeyword @RequestorMapUserId = 1, @Keyword = N'[object Object]'
CREATE PROCEDURE [map].[CPUser_FindByKeyword]
	@RequestorMapUserId smallint,
	@Keyword nvarchar(50)
AS
BEGIN

	IF @Keyword IS NULL OR LEN(@Keyword) < 4 RETURN

	DECLARE @SearchPattern nvarchar(51) = @Keyword + '%'
	
	SELECT TOP (100) a.AccountUid, a.AccountId, a.AccountName, a.CompanyName, u.UserId, u.Login, u.Firstname, u.Lastname, u.SecretKey
	FROM cp.Account a
		INNER JOIN cp.[User] u ON a.AccountUid = u.AccountUid and u.UserStatus = 'A'
	WHERE (a.AccountId LIKE @SearchPattern
		OR a.AccountName LIKE @SearchPattern
		OR a.CompanyName LIKE @SearchPattern
		OR u.Login LIKE '%' + @Keyword + '%'
		OR u.Lastname LIKE @SearchPattern
		OR u.Firstname LIKE @SearchPattern)
END
