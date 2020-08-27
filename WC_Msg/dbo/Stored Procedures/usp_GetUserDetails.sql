
CREATE PROCEDURE [dbo].[usp_GetUserDetails]
	@username NVARCHAR(200),
	@password NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT acc.AccountId, acc.SubAccountId, acc.Active as IsSubAccountActive,
		usr.Active as IsUserActive, acd.Password as APIPassword
	FROM dbo.Users usr 
		inner join dbo.Account acc on usr.AccountId = acc.AccountId
		inner join dbo.AccountCredentials acd on usr.AccountId = acd.AccountId
	WHERE usr.Username = @username 
		and usr.Password=@password COLLATE SQL_Latin1_General_CP1_CS_AS
		--and usr.Active=1 --and acc.Active=1
END
