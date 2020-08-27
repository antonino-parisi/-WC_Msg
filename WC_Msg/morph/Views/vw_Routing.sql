CREATE VIEW [morph].[vw_Routing]
AS
	SELECT r.[RuleId]
		  ,[SubAccountId]
		  ,[Country]
		  ,r.[OperatorId]
		  ,o.OperatorName
		  ,[IsActiveRoute]
		  ,[RouteStrategy]
		  ,[Currency]
		  ,[Price]
		  ,[UseCheapestRoute]
		  ,[DataSourceId]
		  ,r.[CreatedTimeUtc] as R_CreatedTimeUtc
		  ,r.[LastModifiedTimeUtc] as R_LastModifiedTimeUtc
		  ,[SubRuleId]
		  ,[StartTime]
		  ,[EndTime]
		  ,[Weight]
		  ,[RouteId]
		  ,rr.CreatedTimeUtc as RR_CreatedTimeUtc
		  ,rr.LastModifiedTimeUtc as RR_LastModifiedTimeUtc
	FROM morph.[Routing] r 
		LEFT JOIN morph.[RoutingRule] rr ON r.RuleId = rr.RuleId
		LEFT JOIN mno.Operator o ON r.OperatorId = o.OperatorId
