
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-18
-- =============================================
CREATE PROCEDURE [cp].[Account_UpdateByUserId]
	@UserId uniqueidentifier,				--filter
	@AccountId varchar(50),					--filter
	@AccountName varchar(40),				--new value
	@CompanyName nvarchar(255) = NULL,		--new value
	@Country char(2) = NULL,				--new value
	@CompanyAddress nvarchar(500) = NULL,	--new value
	@InvoiceEmails nvarchar(500) = NULL		--new value
AS
BEGIN

	UPDATE a
	SET AccountName = @AccountName, CompanyName = @CompanyName,
		Country = @Country, CompanyAddress = @CompanyAddress, InvoiceEmails = @InvoiceEmails,
		UpdatedAt = GETUTCDATE()
	FROM cp.Account a
	WHERE a.AccountId = @AccountId AND EXISTS(SELECT 1 FROM cp.[User] WHERE UserId = @UserId AND AccountId = @AccountId)

	EXEC cp.Account_GetByUserId @UserId = @UserId, @AccountId = @AccountId
END

