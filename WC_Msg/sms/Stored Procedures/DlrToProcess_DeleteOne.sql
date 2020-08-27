-- =============================================
-- Author:		Sadeep Madurange
-- Create date: 2020-01-30
-- Description:	Deletes records that are already processed.
-- =============================================
CREATE PROCEDURE [sms].[DlrToProcess_DeleteOne]
    @Umid UNIQUEIDENTIFIER,
	@StatusId tinyint
AS
    IF (@Umid IS NULL)
        THROW 70001, 'Umid: Cannot be null', 1;
        
    DELETE FROM sms.DlrToProcess 
	WHERE Umid = @Umid AND StatusId = @StatusId;
