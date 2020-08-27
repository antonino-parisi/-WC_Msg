-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-31
-- Description:	Data for RoutingMatrix. List of all CustomerRouting
-- =============================================
CREATE PROCEDURE [dbo].[sp_RoutingMatrix_PopulateCustomerRouting]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT cr.AccountId, cr.CustomerConnectionId
	FROM dbo.CustomerRouting cr
	WHERE
		cr.SubAccountUid IS NULL -- for compatibility with older MS version
		AND EXISTS (
			SELECT 1 
			FROM dbo.CustomerConnections cc 
			WHERE cc.CustomerConnectionId = cr.CustomerConnectionId AND cc.Active = 1
		)

END

