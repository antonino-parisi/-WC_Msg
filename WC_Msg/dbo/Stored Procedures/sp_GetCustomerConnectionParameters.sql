-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-04-01
-- Description:	Get Customer Connection parameters
-- =============================================
-- EXEC [dbo].[sp_GetCustomerConnectionParameters] @CustomerConnectionId='Kannel'
CREATE PROCEDURE [dbo].[sp_GetCustomerConnectionParameters]
	@CustomerConnectionId VARCHAR(50)		
AS
BEGIN
	
	SELECT CustomerConnectionId, ParameterName, ParameterValue 
	FROM CustomerConnectionParameters
	WHERE CustomerConnectionId = @CustomerConnectionId

	---- TODO: rewrite it ASAP. Only for migration to AWS. Anton 2016-06-28
	--IF ms.ClusterGroup_GetId() = 'AWS-Cluster1' AND @CustomerConnectionId = 'Kannel'
	--BEGIN
	--	SELECT CustomerConnectionId, ParameterName, 'http://callback.smpp.wavecell.io:13014/' AS ParameterValue 
	--	FROM CustomerConnectionParameters
	--	WHERE CustomerConnectionId = @CustomerConnectionId
	--END
	--ELSE
	--BEGIN
	--	SELECT CustomerConnectionId, ParameterName, ParameterValue 
	--	FROM CustomerConnectionParameters
	--	WHERE CustomerConnectionId = @CustomerConnectionId
	--END
END