-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-11-16
-- =============================================
CREATE PROCEDURE [ms].[AccountMTConfig_GetDLRLevels]
AS
BEGIN
	SELECT [SubAccountId]
		  ,[DeliveryReportLevel]
	FROM [dbo].[AccountMTConfig]
END
