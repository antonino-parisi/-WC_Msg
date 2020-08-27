

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-01-22
-- One-Way Insert-only Sync of MO and DR connections
-- =============================================
-- EXEC ms.job_MoConnection_Merge
CREATE PROCEDURE [ms].[job_CustomerWebhook_MergeFromV1]
AS
BEGIN

	--- Temporal table for Sync
	DECLARE @CustomerWebhookSync AS TABLE (
	    AccountUid UNIQUEIDENTIFIER,
	    SubAccountUid INT,
	    Type VARCHAR(5),
	    Url NVARCHAR(500),
	    Version TINYINT DEFAULT 1,
	    HttpAuthorizationHeader NVARCHAR(1024),
	    Active BIT DEFAULT 1,
	    HttpContentType VARCHAR(50) DEFAULT 'application/json',
	    HttpTimeoutSec INT DEFAULT 30,
	    ConnectionType VARCHAR(3) DEFAULT 'STD',
	    CustomerConnectionId VARCHAR(50)
    );

	--- populate MO data
	INSERT INTO @CustomerWebhookSync (AccountUid, SubAccountUid, type, url, Version,  httpauthorizationheader, Active, HttpContentType, ConnectionType, CustomerConnectionId)
	SELECT a.AccountUid AS [AccountUid],
		   r.SubAccountUid AS [SubAccountUid],
		   'MO' AS [Type],
		   c.Url AS [Url],
		   c.Version AS Version,
		   c.Auth AS HttpAuthorizationHeader,
		   cc.Active,
		   CASE WHEN c.Version = 1 THEN 'text/xml'
				WHEN c.Version = 2 THEN 'application/json'
				WHEN c.Version = 5 THEN 'application/x-www-form-urlencoded' END AS HttpContentType,
		   CASE WHEN cc.ClassName = 'NozaraConnections.Http.KannelConnection' THEN 'KAN'
				WHEN cc.ClassName = 'NozaraConnections.Http.StandardConnection' THEN 'STD' END AS ConnectionType,
		   CASE WHEN c.Version = 1 THEN c.CustomerConnectionId END AS CustomerConnectionId
	FROM 
		-- previous MO data structure
		(SELECT
			cc1.CustomerConnectionId,
			MAX(IIF(cc2.ParameterName = 'MOConnectionAddress', cc2.ParameterValue, NULL)) AS [Url],
			MAX(IIF(cc2.ParameterName = 'HttpMOAuthorization', cc2.ParameterValue, NULL)) AS [Auth],
			MAX(IIF(cc2.ParameterName = 'HttpMOVersion', cc2.ParameterValue, 1))          AS [Version]
		FROM dbo.CustomerConnectionParameters cc1
			INNER JOIN dbo.CustomerConnectionParameters cc2 ON cc1.CustomerConnectionId = cc2.CustomerConnectionId
		WHERE
			cc1.ParameterName = 'MOConnectionAddress'
			AND cc2.ParameterName IN ('MOConnectionAddress', 'HttpMOAuthorization', 'HttpMOVersion')
		GROUP BY cc1.CustomerConnectionId) AS c
		INNER JOIN dbo.CustomerRouting r ON r.CustomerConnectionId = c.CustomerConnectionId
		INNER JOIN cp.Account a ON r.AccountId = a.AccountId
		INNER JOIN dbo.CustomerConnections cc ON c.CustomerConnectionId = cc.CustomerConnectionId;

	--- populate DR data
    INSERT INTO @CustomerWebhookSync (AccountUid, SubAccountUid, type, url, Version,  httpauthorizationheader, Active, HttpContentType, ConnectionType, HttpTimeoutSec, CustomerConnectionId)
    SELECT a.AccountUid AS [AccountUid],
           r.SubAccountUid AS [SubAccountUid],
           'DR' AS [Type],
           c.Url AS [Url],
           IIF(c.Version IS NULL, 6, c.Version) AS Version,
           c.Auth AS HttpAuthorizationHeader,
           cc.Active,
           CASE WHEN c.Version = 1 THEN 'text/xml'
                WHEN c.Version = 2 THEN 'text/xml'
                WHEN c.Version = 3 THEN 'text/xml'
                WHEN c.Version = 5 THEN 'application/x-www-form-urlencoded'
                ELSE 'application/json'
               END AS HttpContentType,
           CASE WHEN cc.ClassName = 'NozaraConnections.Http.KannelConnection' THEN 'KAN'
                WHEN cc.ClassName = 'NozaraConnections.Http.StandardConnection' THEN 'STD' END AS ConnectionType,
           IIF(c.Timeouts IS NULL, 30, c.Timeouts / 1000) AS HttpTimeoutSec,
           CASE WHEN c.Version = 1 THEN c.CustomerConnectionId END AS CustomerConnectionId
    FROM 
		-- previous DR data structure 
		(SELECT 
			cc1.CustomerConnectionId,
			MAX(CASE WHEN cc2.ParameterName = 'DRConnectionAddress' THEN cc2.ParameterValue END)  AS [Url],
			MAX(CASE WHEN cc2.ParameterName = 'HttpDLRAuthorization' THEN cc2.ParameterValue END) AS [Auth],
			MAX(CASE WHEN cc2.ParameterName = 'HttpDLRVersion' THEN cc2.ParameterValue END)       AS [Version],
			MAX(CASE WHEN cc2.ParameterName = 'HttpDRTimeoutsMs' THEN cc2.ParameterValue END)     AS [Timeouts]
		FROM dbo.CustomerConnectionParameters cc1
			INNER JOIN dbo.CustomerConnectionParameters cc2 ON cc1.CustomerConnectionId = cc2.CustomerConnectionId
		WHERE cc1.ParameterName = 'DRConnectionAddress'
		  AND cc2.ParameterName IN ('DRConnectionAddress', 'HttpDLRAuthorization', 'HttpDLRVersion', 'HttpDRTimeoutsMs', 'HttpDLRMethodType')
		GROUP BY cc1.CustomerConnectionId) AS c
		INNER JOIN dbo.CustomerRouting r ON r.CustomerConnectionId = c.CustomerConnectionId
		INNER JOIN cp.Account a ON r.AccountId = a.AccountId
		INNER JOIN dbo.CustomerConnections cc ON c.CustomerConnectionId = cc.CustomerConnectionId;

	-- One-way insert only sync
	INSERT INTO ms.CustomerWebhook (AccountUid, SubAccountUid, Type, Url, Version, HttpAuthorizationHeader, Active, HttpContentType, ConnectionType, HttpTimeoutSec, CustomerConnectionId)
	SELECT AccountUid, SubAccountUid, Type, Url, Version, HttpAuthorizationHeader, Active, HttpContentType, ConnectionType, HttpTimeoutSec, CustomerConnectionId
	FROM @CustomerWebhookSync s
	WHERE NOT EXISTS (
	    SELECT 1 FROM ms.CustomerWebhook w
	    WHERE w.AccountUid = s.AccountUid AND
	          ((w.SubAccountUid IS NULL AND s.SubAccountUid IS NULL) OR
	           (w.SubAccountUid = s.SubAccountUid)) AND
	          w.Type = s.Type);
END
