
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-08-20
-- Description:	Load WhatsApp template maps
-- =============================================
CREATE PROCEDURE [ipm].[WhatsAppTemplateCategory_GetAll]
AS
BEGIN
	SELECT CategoryId, CategoryName, UserFriendlyName
	FROM ipm.WhatsAppTemplateCategory
END
