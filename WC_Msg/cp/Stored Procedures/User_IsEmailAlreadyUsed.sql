
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-11-11
-- =============================================
-- EXEC cp.User_IsEmailAlreadyUsed @Email='abcd@abcd.sg'
CREATE PROCEDURE [cp].[User_IsEmailAlreadyUsed]
	@Email nvarchar(255)
AS
BEGIN

	SELECT COUNT(UserId) AS EmailAlreadyUsed 
	FROM cp.[User]
	WHERE Login = @Email AND UserStatus IN ('A', 'I', 'B')

END

