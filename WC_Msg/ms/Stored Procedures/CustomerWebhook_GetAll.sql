
---
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-08-13
-- Description:	Get All config from ms.CustomerWebhook.
-- =============================================
CREATE PROCEDURE [ms].[CustomerWebhook_GetAll]
AS
BEGIN
	SELECT 
		w.AccountUid,
		w.SubAccountUid,
		w.[Type], 
		w.[Url], 
		w.[Version], 
		w.HttpMethod, 
		w.HttpAuthorizationHeader,
		w.HttpContentType,
		w.HttpTimeoutSec,
		w.ConnectionType,
		w.MediaUrlExpiryDays,
		w.CustomerConnectionId
	FROM ms.CustomerWebhook w
	WHERE w.Active = 1
END
