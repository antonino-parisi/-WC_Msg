-- =============================================
-- Author:		<Raju,Gupta>
-- Create date: <Create Date,03032015,>
-- Description:	Update routing from View Routing
-- =============================================
CREATE PROCEDURE [dbo].[usp_updateViewRoutingRow]  
@AccountId NVARCHAR(50),
@Subaccountid NVARCHAR(50),
@RouteId NVARCHAR(50),
@Prefix NVARCHAR(50),
@Operator nvarchar(50),
@Price float,
@Cost float,
@Priority int,
@RoutingMode int,
@Active bit

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
UPDATE PlanRouting SET RouteId =@RouteId, 
Price =@Price,
Cost =@Cost, 
Priority =@Priority, 
Active =@Active,
RoutingMode=@RoutingMode 
WHERE AccountId =@AccountId 
AND SubAccountId  =@Subaccountid 
AND Prefix =@Prefix  
and Operator=@Operator
END
