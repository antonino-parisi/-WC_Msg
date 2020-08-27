-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-09-04
-- Description:	Delete whatsapp media by id
-- =============================================
CREATE PROCEDURE [ipm].[WhatsAppMedia_Delete]
	@MediaId uniqueidentifier
AS
BEGIN
	DELETE FROM ipm.WhatsAppMedia WHERE Id = @MediaId
END
