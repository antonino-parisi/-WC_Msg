-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,22-04-2013,>
-- Description:	<Insert selected route Session data>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InsertRouteSelData]
	-- Add the parameters for the stored procedure here
		@AccountId NVARCHAR(50),
		@SubAccountId NVARCHAR(50),
		@Operator NVARCHAR(200),
		@RouteId NVARCHAR(50),
		@SessionId NVARCHAR(250),
		@Status int
		
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



INSERT INTO [dbo].[RouteSelSessionData]
           ([AccountId]
           ,[SubAccountId]
           ,[RouteId]
           ,[Operator]
           ,[SessionId]
           ,[DateTime],[Status])
     VALUES
			(@AccountId
           ,@SubAccountId
           ,@RouteId
           ,@Operator
           ,@SessionId,GETDATE(),@Status)
           

  UPDATE dbo.CostSessionData SET Active=null where AccountId=@AccountId AND SubAccountId=@SubAccountId AND Operator=@Operator AND SessionId=@SessionId
  UPDATE dbo.CostSessionData SET Active=1 where AccountId=@AccountId AND SubAccountId=@SubAccountId AND Operator=@Operator AND SessionId=@SessionId AND RouteId=@RouteId


END







