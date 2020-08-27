-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-29
-- Description:	Return next best available SenderId from SenderRotationPool, by SenderPoolId
--				can return NULL if SenderRotationPool is empty
-- =============================================
-- Examples:
-- EXEC [optimus].[SenderRotationPoolList_GetNewSenderId] @SenderPoolId = 1, @ShiftNextAvailabilityInMins = 1  --make a time shift for returned SenderId
-- EXEC [optimus].[SenderRotationPoolList_GetNewSenderId] @SenderPoolId = 1
-- =============================================
CREATE PROCEDURE [optimus].[SenderRotationPoolList_GetNewSenderId] (
	@SenderPoolId smallint,
	@ShiftNextAvailabilityInMins int = 0
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SenderId varchar(16)

	SELECT TOP 1 @SenderId = LTRIM(RTRIM(SenderId))
	FROM optimus.SenderRotationPoolList
	WHERE SenderPoolId = @SenderPoolId
	ORDER BY NextAvailabilityTimeUtc

	IF (@ShiftNextAvailabilityInMins > 0)
	BEGIN
		UPDATE optimus.SenderRotationPoolList
		SET NextAvailabilityTimeUtc = DATEADD(minute, @ShiftNextAvailabilityInMins, NextAvailabilityTimeUtc)
		WHERE SenderPoolId = @SenderPoolId AND SenderId = @SenderId

		--PRINT 'NextAvailabilityTimeUtc updated'
	END

	SELECT @SenderId as SenderId
END
