
-- =============================================
-- Author:		Nathanael Hinay
-- Create date: 2020-06-19
-- Description:	Insert email to cp.AccountEmail
-- =============================================
-- EXEC map.Account_Email_Create @AccountUid = '2318bdeb-c250-e711-8141-06b9b96ca965', @Email = 'michael.ocarol+12312@wavecell.com', @Type = 'TO', @FlagPricing = 1
CREATE PROCEDURE [map].[Account_Email_Create]
	@AccountUid UNIQUEIDENTIFIER,
	@Email NVARCHAR(100),
	@Type VARCHAR(3),
    @FlagPricing bit = NULL,
    @FlagInvoice bit = NULL,
    @FlagProductNews bit = NULL,
    @FlagTech bit = NULL
AS
BEGIN

    INSERT INTO cp.AccountEmail (AccountUid, Email, Type, FlagPricing, FlagInvoice, FlagProductNews, FlagTech)
    VALUES (@AccountUid, @Email, @Type, ISNULL(@FlagPricing, 0), ISNULL(@FlagInvoice, 0), ISNULL(@FlagProductNews, 0), ISNULL(@FlagTech, 0))

END
