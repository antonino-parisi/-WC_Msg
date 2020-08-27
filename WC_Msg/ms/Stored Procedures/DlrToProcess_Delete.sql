-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-03-17
-- Description:	Delete scheduled DR message
-- =============================================
CREATE PROCEDURE [ms].[DlrToProcess_Delete]
	@UMID uniqueidentifier,
	@StatusId tinyint
AS
BEGIN
	DELETE FROM sms.DlrToProcess 
	WHERE UMID = @UMID AND StatusId = @StatusId
END
