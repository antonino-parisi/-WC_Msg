-- =============================================
-- Author:		Nathanael Hinay
-- Create date: 2018-06-20
-- =============================================
-- EXEC cp.[UserSubAccount_Get] @UserId='90a8c984-d710-4de1-a465-8c5ff2daa7db'
CREATE PROCEDURE [cp].[UserSubAccount_Get]
	@UserId uniqueidentifier
AS
BEGIN
	SELECT sa.SubAccountId 
	FROM cp.UserSubAccount us
		INNER JOIN dbo.Account sa ON us.SubAccountUid = sa.SubAccountUid
	WHERE us.UserId = @UserId
END
