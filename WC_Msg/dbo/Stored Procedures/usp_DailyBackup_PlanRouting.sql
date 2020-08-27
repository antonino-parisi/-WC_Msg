-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,26-06-2014,>
-- Description:	<Insert Formula>
-- =============================================
CREATE PROCEDURE [dbo].[usp_DailyBackup_PlanRouting]
	-- Add the parameters for the stored procedure here
		
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DELETE FROM PlanRoutingBackup

	INSERT INTO PlanRoutingBackup 
	SELECT [AccountId]
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
	FROM PlanRouting

	IF @@ERROR = 0
		UPDATE ApplicationSettings set ParameterValue=GETDATE() where ParameterName='PlanRoutingLastBackup'
	
	
	--Begin Try
	--delete from PlanRoutingBackup
	--INSERT INTO PlanRoutingBackup SELECT * FROM PlanRouting
	-- update ApplicationSettings set ParameterValue=GETDATE() where ParameterName='PlanRoutingLastBackup'
	-- end try
	-- begin catch
	-- DECLARE @ErrorMessage NVARCHAR(4000);
	--DECLARE @ErrorSeverity INT;
	--DECLARE @ErrorState INT;

	--SELECT 
	--    @ErrorMessage = ERROR_MESSAGE(),
	--    @ErrorSeverity = ERROR_SEVERITY(),
	--    @ErrorState = ERROR_STATE();

	---- Use RAISERROR inside the CATCH block to return error
	---- information about the original error that caused
	---- execution to jump to the CATCH block.
	--RAISERROR (@ErrorMessage, -- Message text.
	--           @ErrorSeverity, -- Severity.
	--           @ErrorState -- State.
	--           );
	--  end catch
    
    
END









