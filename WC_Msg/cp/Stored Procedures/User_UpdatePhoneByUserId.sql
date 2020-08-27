
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-07-28
-- =============================================
-- EXEC cp.User_UpdatePhoneByUserId @UserId = '9F5F15C4-3EBC-4BF5-B790-3085F0A3C468', @MSISDN = 6587093459, @PhoneVerified = 1
CREATE PROCEDURE [cp].[User_UpdatePhoneByUserId]
	@UserId UNIQUEIDENTIFIER,
	@Phone varchar(20) = NULL,
	@MSISDN bigint = NULL, -- please set @MSISDN instead of @Phone (if you can cast phonenumber to bigint)
	@PhoneVerified bit
AS
BEGIN

	SET @MSISDN = TRY_CAST(@Phone as bigint)

	UPDATE cp.[User]
	SET Phone = @Phone, MSISDN = @MSISDN,
		PhoneVerified = IIF(@MSISDN IS NOT NULL, @PhoneVerified, 0), UpdatedAt = GETUTCDATE()
	WHERE UserId = @UserId

END
