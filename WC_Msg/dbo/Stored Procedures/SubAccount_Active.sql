

CREATE PROCEDURE dbo.SubAccount_Active
AS
BEGIN
	SET NOCOUNT ON;

	SELECT [AccountId], [SubAccountId]
	FROM [dbo].[Account]
	WHERE Active = 1

END
