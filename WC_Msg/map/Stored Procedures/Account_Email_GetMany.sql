-- =============================================
-- Author:		Nathanael O. Hinay
-- Create date: 2020-06-30
-- Description:	Emails of Accounts for pricing notifications in AM
-- =============================================
-- Examples:
--	EXEC map.[Account_Email_GetMany] @AccountUid = '16d9fff3-b61f-e911-814f-06b9b96ca965'
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
--

CREATE PROCEDURE [map].[Account_Email_GetMany]
	@AccountUid UNIQUEIDENTIFIER,
    @FlagPricing bit = NULL, -- filter for pricing emails
    @FlagInvoice bit = NULL, -- filter for invoice emails
    @FlagTech bit = NULL, -- filter for technical emails
    @FlagProductNews bit = NULL -- filter for product news
AS
BEGIN

    SELECT id as ID, Email, Type, FlagPricing, FlagInvoice, FlagTech, FlagProductNews
    FROM cp.AccountEmail ae
    WHERE ae.AccountUid = @AccountUid
        AND (@FlagPricing IS NULL OR ae.FlagPricing = @FlagPricing)
        AND (@FlagInvoice IS NULL OR ae.FlagInvoice = @FlagInvoice)
        AND (@FlagTech IS NULL OR ae.FlagTech = @FlagTech)
        AND (@FlagProductNews IS NULL OR ae.FlagProductNews = @FlagProductNews)
	
END
