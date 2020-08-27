-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-21
-- Description:	update NextAvailabilityTimeUtc for SenderPoolId + SenderId
-- =============================================
CREATE PROCEDURE [optimus].[SenderRotationPoolList_UpdateNextAvailability]
	@SenderPoolId smallint,
	@SenderId varchar(16),
	@NextAvailabilityTimeUtc datetime = NULL
AS
BEGIN
	
	IF (@NextAvailabilityTimeUtc IS NULL) SET @NextAvailabilityTimeUtc = GETUTCDATE()

	UPDATE optimus.SenderRotationPoolList
	SET NextAvailabilityTimeUtc = @NextAvailabilityTimeUtc
	WHERE SenderPoolId = @SenderPoolId AND SenderId = @SenderId

END
