-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-21
-- Description:	get data for SenderRotationPoolList
-- =============================================
CREATE PROCEDURE [optimus].[SenderRotationPoolList_GetById]
	@SenderPoolId smallint
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SenderId, NextAvailabilityTimeUtc
	FROM optimus.SenderRotationPoolList
	WHERE SenderPoolId = @SenderPoolId
		AND NextAvailabilityTimeUtc <= GETUTCDATE()

END
