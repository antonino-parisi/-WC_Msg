-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2018-09-21
-- Description:	get all data from MessageBodyPrefixRules table
-- =============================================
CREATE PROCEDURE [optimus].[MessageBodyPrefixRules_GetAll]
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
		Country,
		OperatorId,
		AccountId,
		SubAccountId,
		RouteId,
		Priority,
		Prefix,
		ExcludePattern
	FROM optimus.MessageBodyPrefixRules

END
