CREATE PROCEDURE [dbo].[sp_GetScheduledMessages]
AS
BEGIN
	UPDATE TOP (10000) ScheduledMessages SET transmitting = 1    
	OUTPUT inserted.*
	WHERE ScheduledDateTime <= GETUTCDATE() and transmitting=0
END

