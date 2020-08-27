-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-21
-- Description:	get data for SenderRotationPool
-- =============================================
CREATE PROCEDURE [optimus].[SenderRotationPool_GetAll]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SenderPoolId, SenderPoolName, SenderPoolDescription, JsonSettings
	FROM optimus.SenderRotationPool
END
