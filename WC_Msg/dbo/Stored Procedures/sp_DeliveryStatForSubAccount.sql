-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_DeliveryStatForSubAccount]
	-- Add the parameters for the stored procedure here
@begin date,
@end date,
@SubAccountId NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select RouteIdUsed,ISNULL(country,Trafficrecord.OperatorId) as country, ISNULL(Operatorname,'Not in numbering plan') AS Operatorname,status ,COUNT(*) as total from TrafficRecord LEFT JOIN  Operator ON Trafficrecord.OperatorId = Operator.OperatorId 
			where SubAccountId=@SubAccountId 
			and Datetimestamp>@begin
			and  Datetimestamp<@end
			group  by RouteIdUsed,country,Operatorname,Trafficrecord.OperatorId,status order by total desc;

END
