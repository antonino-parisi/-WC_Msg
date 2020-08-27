-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-10
-- =============================================
-- EXEC cp.UiActivity_GetMany ....
CREATE PROCEDURE [cp].[UiActivity_GetMany]
	@AccountUid uniqueidentifier,
	@Limit smallint = 10
AS
BEGIN
	
	SELECT TOP (@Limit) ua.ActivityId, ua.AccountUid, ua.Message, ua.CreatedBy, ua.CreatedAt, u.Firstname, u.Lastname, u.Login
	FROM cp.UiActivity ua
		LEFT JOIN cp.[User] u ON ua.CreatedBy = u.UserId AND ua.AccountUid = u.AccountUid
	WHERE ua.AccountUid = @AccountUid
	ORDER BY ua.CreatedAt DESC
END
