-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-18
-- =============================================
-- SELECT * FROM cp.[User] WHERE UserId = '9F5F15C4-3EBC-4BF5-B790-3085F0A3C468'
-- EXEC cp.User_UpdateByUserId @UserId = '9F5F15C4-3EBC-4BF5-B790-3085F0A3C468', @Firstname = 'Firstname', @Lastname = 'Lastname', @Phone = '6587090000', @TimeZoneId = 0
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 09/01/2019  Rebecca  added column OptIn_Marketing column

CREATE PROCEDURE [cp].[User_UpdateByUserId]
	@UserId UNIQUEIDENTIFIER,
	@Firstname nvarchar(255) = NULL,
	@Lastname nvarchar(255) = NULL,
	@Phone varchar(20) = NULL,
	@TimeZoneId smallint = NULL,
	@OptIn_Marketing bit = 0
AS
BEGIN
	DECLARE @MSISDN bigint ;
	
	SET @MSISDN = CASE WHEN @Phone IS NOT NULL THEN TRY_CAST(@Phone as bigint) ELSE NULL END;

    UPDATE cp.[User]
    SET Firstname = ISNULL(@Firstname, Firstname),
        Lastname = ISNULL(@Lastname, Lastname),
        Phone = ISNULL(@Phone, Phone),
        MSISDN = CASE WHEN @Phone IS NULL THEN MSISDN ELSE TRY_CAST(@Phone as bigint) END,
        PhoneVerified = IIF(PhoneVerified = 1 AND MSISDN = @MSISDN, 1, 0),
        TimeZoneId = ISNULL(@TimeZoneId, TimeZoneId),
        OptIn_Marketing =ISNULL(@OptIn_Marketing, OptIn_Marketing),
        UpdatedAt = GETUTCDATE()
    WHERE UserId = @UserId;
END
