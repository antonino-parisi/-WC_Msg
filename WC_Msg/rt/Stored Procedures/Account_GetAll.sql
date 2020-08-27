
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-05-10
-- Description:	List of all accounts
-- =============================================
-- Examples:
-- EXEC rt.[Account_GetAll]
-- =============================================
CREATE PROCEDURE [rt].[Account_GetAll]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT a.AccountId, a.SubAccountId
	FROM dbo.Account a
	WHERE a.Active = 1
	ORDER BY 1, 2
END
