CREATE PROCEDURE [dbo].[sp_UpdateMORecordStatusCIdBySubAccountIdUmid]
			@UMID VARCHAR(50),
			@SubAccountId VARCHAR(50),
			@Status VARCHAR(50),
			@AdditionalInfo NVARCHAR(255) 
AS
SET NOCOUNT ON;
update [dbo].[TrafficRecord] 
set Status = @Status, AdditionalInfo = @AdditionalInfo, DateTimeUpdated = getutcdate() 
where UMID = @UMID and SubAccountId = @SubAccountId and MessageType = 'MO'
