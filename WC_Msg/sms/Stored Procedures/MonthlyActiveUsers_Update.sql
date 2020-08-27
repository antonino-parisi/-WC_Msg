-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-01-10
-- =============================================
CREATE PROCEDURE sms.MonthlyActiveUsers_Update
	@AccountId varchar(50),
	@Year int,
	@Month tinyint,
	@UsersEstimate int
AS
BEGIN 

	DECLARE @AccountUid uniqueidentifier

	SELECT @AccountUid = AccountUid FROM cp.Account a WHERE a.AccountId = @AccountId

	UPDATE sms.MonthlyActiveUsers 
	SET UsersEstimate = @UsersEstimate
	WHERE 
		AccountUid = @AccountUid 
		AND Year = @Year 
		AND Month = @Month
  
	IF @@ROWCOUNT = 0
		INSERT INTO sms.MonthlyActiveUsers (AccountUid, Year, Month, UsersEstimate)
		VALUES (@AccountUid, @Year, @Month, @UsersEstimate)
END
