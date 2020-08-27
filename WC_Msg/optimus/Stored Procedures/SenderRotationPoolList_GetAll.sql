-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2018-05-10
-- Description:	get data for SenderRotationPoolList
-- =============================================
CREATE PROCEDURE [optimus].[SenderRotationPoolList_GetAll]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SenderPoolId, SenderId, NextAvailabilityTimeUtc
	FROM optimus.SenderRotationPoolList
END
