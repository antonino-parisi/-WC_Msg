CREATE PROCEDURE [dbo].[AccountCredential_GetAll]
AS
BEGIN
	SELECT 
		 [AccountId]
		  ,[Password]
		  ,[isEncrypted]
		  ,[Description]
		  ,[date]
		  ,[overdraftAuthorized]
		  ,NULL AS [Validate]
		  ,NULL AS [ValidationTag]
		  ,NULL AS [PrivateMTQueue]
		  ,[AlertValue]
		  ,[OutOfCredit]
		  ,[IsVerified]
	FROM [dbo].[AccountCredentials]

END
