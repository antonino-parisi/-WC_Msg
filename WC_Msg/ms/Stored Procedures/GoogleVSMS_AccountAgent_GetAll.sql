

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-06-29
-- Description:	Get Google VSMS account configuration
-- =============================================
CREATE PROCEDURE [ms].[GoogleVSMS_AccountAgent_GetAll]	
--WITH EXECUTE AS OWNER
AS
BEGIN

	SELECT 
		aa.AccountUid,
		aa.SubAccountUid,
		a.AgentId,
		s.Country,
		s.SenderId
	FROM ms.GoogleVSMS_AccountAgent AS aa
		INNER JOIN ms.GoogleVSMS_Agent AS a ON aa.AgentId = a.AgentId
		INNER JOIN ms.GoogleVSMS_SenderId AS s ON a.AgentId = s.AgentId
	WHERE a.Active = 1
	
END
