CREATE PROCEDURE [dbo].[usp_Customer_EmailId_For_Balance_Alert]
			@AccountId nvarchar(50)
			
								
AS
SELECT [EmailAddress] as OpToemail,CCEmailAddress as OpCCemail,BCCEmailAddress as OpBCCemail,SalesTOEmail,SalesCCEmailAddress ,SalesBCCEmailAddress, 
FinanceToEmailAddress,FinanceCCEmailAddress,FinanceBCCEmailAddress,SupportToEmailAddress,SupportCCEmailAddress,SupportBCCEmailAddress                         
  FROM [dbo].[Users] 
  where AccountId=@AccountId 