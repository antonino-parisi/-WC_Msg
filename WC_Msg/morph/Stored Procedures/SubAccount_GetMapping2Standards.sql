
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016/08/08
-- Description:	Get accounts with link to standard subaccounts
-- =============================================
CREATE PROCEDURE morph.[SubAccount_GetMapping2Standards]
WITH EXECUTE AS 'dbo'
AS
BEGIN
	SELECT a.SubAccountId, CAST(sa.SubAccountId as varchar(50)) as StandardSubAccountId
	FROM dbo.Account a
		INNER JOIN dbo.StandardAccount sa ON a.StandardRouteId = sa.StandardRouteIdName
	WHERE sa.SubAccountId <> '*'
END

