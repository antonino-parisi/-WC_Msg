
-- =============================================
-- Author:		Nathanael Hinay
-- Create date: 2020-06-30
-- Description:	Update email in cp.AccountEmail
-- =============================================
-- EXEC map.Account_Email_Update @AccountUid = '2318bdeb-c250-e711-8141-06b9b96ca965', @ID = 12, @Email = 'michael.ocarol+12312@wavecell.com', @Type = 'TO', @FlagPricing = 1
CREATE PROCEDURE [map].[Account_Email_Update]
	@AccountUid UNIQUEIDENTIFIER,
    @ID INT,
	@Email NVARCHAR(100),
	@Type VARCHAR(3),
    @FlagPricing bit = NULL,
    @FlagInvoice bit = NULL,
    @FlagProductNews bit = NULL,
    @FlagTech bit = NULL
AS
BEGIN

    UPDATE cp.AccountEmail
    SET Email = @Email,
        Type = @Type,
        FlagPricing = ISNULL(@FlagPricing, 0),
        FlagInvoice = ISNULL(@FlagInvoice, 0),
        FlagTech = ISNULL(@FlagTech, 0),
        FlagProductNews = ISNULL(@FlagProductNews, 0)
    WHERE id = @ID AND AccountUid = @AccountUid;

END
