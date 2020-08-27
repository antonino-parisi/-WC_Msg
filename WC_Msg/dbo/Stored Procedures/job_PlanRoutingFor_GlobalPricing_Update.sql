-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-09-14
-- Description:	
--		Logic of updating PlanRoutingFor_GlobalPricing removed from TRIGGER [dbo].[updateServer_PlanRouting] (where its executing on every record)
--		It's OK to execute this update with delay.
--		Logic might be implementated in better way if we have time for this
-- =============================================
CREATE PROCEDURE [dbo].[job_PlanRoutingFor_GlobalPricing_Update]
AS
BEGIN
	
	DECLARE @LastChangedTime datetime

	SELECT TOP (1) @LastChangedTime = ChangedDate
	FROM dbo.PlanRoutingHistory
	ORDER BY id desc

	IF (@LastChangedTime > DATEADD(MINUTE, -15, GETUTCDATE()))
	BEGIN
		--old simplified way of updating PlanRoutingFor_GlobalPricing
		truncate table dbo.PlanRoutingFor_GlobalPricing

		insert into dbo.PlanRoutingFor_GlobalPricing 
		select [AccountId]
		  ,[SubAccountId]
		  ,[Prefix]
		  ,[RouteId]
		  ,[Price]
		  ,[Priority]
		  ,[Active]
		  ,[Operator]
		  ,[TariffRoute]
		  ,[Cost]
		  ,[RoutingMode] 
		from dbo.PlanRouting
	END
END
