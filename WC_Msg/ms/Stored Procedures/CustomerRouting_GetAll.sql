-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-01-21
-- Description:	Load customer routing table
-- =============================================
CREATE PROCEDURE [ms].[CustomerRouting_GetAll]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SubAccountUid, CustomerConnectionId
	FROM (
		SELECT 
			a.SubAccountUid, 
			ISNULL(rS.CustomerConnectionId, rA.CustomerConnectionId) AS CustomerConnectionId
		FROM dbo.Account a
			LEFT JOIN dbo.CustomerRouting rS ON rS.SubAccountUid = a.SubAccountUid
			LEFT JOIN dbo.CustomerRouting rA ON rA.AccountId = a.AccountId AND rA.SubAccountUid IS NULL
		WHERE a.Active = 1
			AND (rS.CustomerConnectionId IS NOT NULL OR rA.CustomerConnectionId IS NOT NULL)
		--ORDER BY A.SubAccountUid
	) t
	WHERE 
		EXISTS (
			SELECT 1 
			FROM dbo.CustomerConnections cc 
			WHERE cc.CustomerConnectionId = t.CustomerConnectionId AND cc.Active = 1
		)

END
