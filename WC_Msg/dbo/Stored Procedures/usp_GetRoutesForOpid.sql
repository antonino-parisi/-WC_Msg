
-- =============================================
-- Author:		Raju Gupta
-- Create date: 19/04/2013
-- Description:	return the routes corresponding to a operatorid
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRoutesForOpid]  
@Operator NVARCHAR(200),
@AccountId NVARCHAR(50),
@SubAccountId NVARCHAR(50),
@SessionId NVARCHAR(250)	

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	
	SELECT RouteId,Price,Cost,'Live' Src,Active CurrentActive FROM PlanRouting WHERE  AccountId=@AccountId AND SubAccountId=@SubAccountId AND Operator=@Operator
	SELECT RouteId,Price,Cost,'File' Src,CurrentActive,Active   FROM CostSessionData WHERE  AccountId=@AccountId AND SubAccountId=@SubAccountId AND Operator=@Operator AND Impact='Yes' AND SessionId=@SessionId
	
  




END

