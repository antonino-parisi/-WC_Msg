-- =============================================
-- Author:		<Raju,Gupta>
-- Create date: <Create Date,19032015,>
-- Description:	Update routing from View Routing
-- =============================================
CREATE PROCEDURE [dbo].[usp_deleteViewRoutingRow]  
@AccountId NVARCHAR(50),
@Subaccountid NVARCHAR(50),
@RouteId NVARCHAR(50),
@Prefix NVARCHAR(50),
@Operator nvarchar(50),
@Priority int

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DELETE FROM PlanRouting WHERE AccountId =@AccountId 
AND SubAccountId  =@Subaccountid 
AND Prefix =@Prefix  
and Operator=@Operator and RouteId=@RouteId and Priority=@Priority
 

END
