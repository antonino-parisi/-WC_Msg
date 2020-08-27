-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-01-12
-- Description:	Api Webhooks - Get by Account
-- =============================================
-- EXEC cp.ApiWebhook_GetByAccount @AccountId='Account1'
CREATE PROCEDURE [cp].[ApiWebhook_GetByAccount]
	@AccountId varchar(50)
AS
BEGIN
	
	-- DEBUG
	--DECLARE @AccountId varchar(50) = 'Account1'
	
	-- Version 1
	SELECT DRConnectionAddress AS DR_Url, ISNULL(HttpDLRMethodType, 'POST') as DR_Method, 'text/xml' as DR_Format
	FROM
	(
		SELECT ccp.ParameterName, ccp.ParameterValue
		FROM dbo.CustomerConnections cc
			INNER JOIN dbo.CustomerRouting cr ON cr.CustomerConnectionId = cc.CustomerConnectionId
			LEFT JOIN dbo.CustomerConnectionParameters ccp ON cc.CustomerConnectionId = ccp.CustomerConnectionId
		WHERE cc.Active = 1 AND cr.AccountId = @AccountId
	) t
	PIVOT (
		MAX(ParameterValue) for ParameterName IN (DRConnectionAddress, HttpDLRMethodType)
	) piv
END
