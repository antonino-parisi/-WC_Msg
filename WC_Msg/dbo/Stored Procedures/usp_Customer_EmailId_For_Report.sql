-- EXEC [dbo].[usp_Customer_EmailId_For_Report] 'sejasa'
CREATE PROCEDURE [dbo].[usp_Customer_EmailId_For_Report]
	@AccountId nvarchar(50)
AS
BEGIN
	SELECT [EmailAddress]                             
	FROM [dbo].[Users] 
	WHERE AccountId=@AccountId AND [EmailAddress] IS NOT NULL
END