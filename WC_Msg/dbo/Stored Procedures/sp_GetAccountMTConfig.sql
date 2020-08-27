
CREATE PROCEDURE [dbo].[sp_GetAccountMTConfig]
AS
	SELECT [SubAccountId]
		  ,[DefaultTPOA]
		  ,[ForceTPOA]
		  ,[DeliveryReportLevel]
		  ,[RoutingMethod]
		  ,[SmartRetry]
		  ,[SmartRetryExpression]
		  ,UseMNOLookup
	FROM [dbo].[AccountMTConfig]


