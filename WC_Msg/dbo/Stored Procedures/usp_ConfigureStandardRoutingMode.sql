-- =============================================
-- Author:		<Raju Gupta>
-- Create date: <04-12-2014,>
-- Description:	<Configure Routing Mode for standard Account id and subaccount id>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ConfigureStandardRoutingMode]
@AccountId as nvarchar(50),
@SubAccountId as nvarchar(50),
@RoutingModeDetails Nvarchar(max)=NULL,
@RoutingModeValue int=NULL
--@StandardRouteIdName as nvarchar(250),
--@ExistingStandardRouteId as nvarchar(250)

AS

BEGIN

Update standardaccount set RoutingMode=@RoutingModeDetails where AccountId=@AccountId  and SubAccountId=@SubAccountId

Update planrouting set RoutingMode=@RoutingModeValue where AccountId=@AccountId  and SubAccountId=@SubAccountId
                                     	
END
