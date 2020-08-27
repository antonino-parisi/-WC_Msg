CREATE PROCEDURE [dbo].[usp_Customer_EmailId_For_PriceChange_Alert]
			@AccountId nvarchar(50)
			
								
AS
SELECT [EmailAddress],CCEmailAddress,BCCEmailAddress                             
  FROM [dbo].[Users] 
  where AccountId=@AccountId 