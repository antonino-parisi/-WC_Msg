-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-03-17
-- Description:	Reset InProcess flag for scheduled DR message
-- =============================================
CREATE PROCEDURE [ms].[DlrToProcess_Reset]
	@UMID uniqueidentifier,
	@StatusId tinyint
AS
BEGIN
	
	UPDATE sms.DlrToProcess 
	SET InProcess = 0
	WHERE UMID = @UMID AND StatusId = @StatusId

END
