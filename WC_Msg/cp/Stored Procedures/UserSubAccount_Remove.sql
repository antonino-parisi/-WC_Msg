-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-06-04
-- =============================================
-- EXEC cp.UserSubAccount_Remove @UserId='...'
CREATE PROCEDURE [cp].[UserSubAccount_Remove]
	--@AccountUid uniqueidentifier,
	@UserId uniqueidentifier,
	@SubAccountId varchar(50)
AS
BEGIN

	DELETE FROM us
	FROM cp.UserSubAccount us
		INNER JOIN dbo.Account sa ON us.SubAccountUid = sa.SubAccountUid
	WHERE us.UserId = @UserId AND sa.SubAccountId = @SubAccountId
END
