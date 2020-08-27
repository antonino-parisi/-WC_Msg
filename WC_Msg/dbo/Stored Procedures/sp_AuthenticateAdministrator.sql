-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Test if the login/password of the administrator is correct ( used by admin portal)
-- =============================================
CREATE PROCEDURE [dbo].[sp_AuthenticateAdministrator]
	-- Add the parameters for the stored procedure here
	@username NVARCHAR(50),
	@password NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE  Administrators set LastLogin=CURRENT_TIMESTAMP where Username=@username  AND Password=@password 
    -- Insert statements for procedure here
	SELECT * FROM Administrators WHERE Username=@username  AND Password=@password 
END
