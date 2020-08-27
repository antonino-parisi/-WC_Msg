
-- =============================================
-- Author:		Nathanael Hinay
-- Create date: 2020-06-30
-- Description:	Delete email to cp.AccountEmail
-- =============================================
-- EXEC map.Account_Email_Create @AccountUid = '2318bdeb-c250-e711-8141-06b9b96ca965', @Email = 'michael.ocarol+12312@wavecell.com', @Type = 'TO', @ID = 12
CREATE PROCEDURE [map].[Account_Email_Delete]
	@AccountUid UNIQUEIDENTIFIER,
    @ID Int,
	@Email NVARCHAR(100),
	@Type VARCHAR(3)
AS
BEGIN

    DELETE FROM cp.AccountEmail
    WHERE AccountUid = @AccountUid
        AND ID = @ID
        AND Email = @Email
        AND Type = @Type

END
