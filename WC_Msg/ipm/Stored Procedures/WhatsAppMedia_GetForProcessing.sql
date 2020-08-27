
-- =============================================
-- Author:		Igor Valyansky
-- Created date: 2019-09-04
-- Description:	Get whatsapp media for processing
-- =============================================
CREATE PROCEDURE [ipm].[WhatsAppMedia_GetForProcessing]
	@CreatedAtThreshold DATETIME2(2)
AS
BEGIN
	DECLARE @now DATETIME2(2) = SYSUTCDATETIME()

	UPDATE TOP (1000) ipm.WhatsAppMedia SET SetInProcessAt = @now    
	OUTPUT inserted.Id AS MediaId, inserted.ChannelId AS WhatsAppId
	WHERE 
		CreatedAt <  @CreatedAtThreshold AND 
		(SetInProcessAt IS NULL OR (SetInProcessAt IS NOT NULL AND DATEDIFF(HOUR, @now, SetInProcessAt) > 1))
END
