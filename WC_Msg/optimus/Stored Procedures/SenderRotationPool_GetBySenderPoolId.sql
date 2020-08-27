-- =============================================
-- Author:		Raymond Torino
-- Create date: 2016-03-28
-- Description:	get data for SenderRotationPool by SenderPoolId
-- =============================================
CREATE PROCEDURE [optimus].[SenderRotationPool_GetBySenderPoolId] (
	@SenderPoolId smallint
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SenderPoolId, SenderPoolName, SenderPoolDescription, JsonSettings
	FROM optimus.SenderRotationPool
	WHERE SenderPoolId = @SenderPoolId
END
