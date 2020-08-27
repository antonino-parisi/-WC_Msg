
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-08-20
-- Description:	Load WhatsApp template maps
-- =============================================
CREATE PROCEDURE [ipm].[WhatsAppTemplateStatus_GetAll]
AS
BEGIN
	SELECT StatusId, StatusCode, UserFriendlyName
	FROM ipm.WhatsAppTemplateStatus
END
