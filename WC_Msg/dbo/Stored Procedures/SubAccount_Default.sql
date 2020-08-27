CREATE PROCEDURE dbo.SubAccount_Default
AS
BEGIN
	SET NOCOUNT ON;

	SELECT [AccountId], [SubAccountId]
	FROM [dbo].[Account]
	WHERE [Default]=1

END
