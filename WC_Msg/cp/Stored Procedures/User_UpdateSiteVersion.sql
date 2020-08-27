-- =============================================
-- Author: Rebecca Loh
-- Create date: 15 May 2019
-- Description: Update cp.[User] with the last portal version they login to
-- Usage : EXEC cp.User_UpdateSiteVersion '9EDC5886-4765-4D79-82F3-02B9D191A507', 'V3'
-- =============================================

CREATE PROCEDURE cp.User_UpdateSiteVersion
	@UserId uniqueidentifier,
	@SiteVersion varchar(5)
AS
BEGIN
    UPDATE cp.[User]
    SET SiteVersion_Current = @SiteVersion,
        UpdatedAt = GETUTCDATE()
    WHERE UserId = @UserId;
END
