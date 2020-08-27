
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	This function is used every minutes by each server to show that it is still alive
-- each server has a counter every minute, it increments its counter and decrements the counter of others server
-- by this way, the server away have a counter that go to 0.
-- if a server which has the least got its counter to 0, it will loose its lead. 
-- =============================================
CREATE PROCEDURE [dbo].[sp_KeepAlive] 
	@MyIp NVARCHAR(50),
	@MyName NVARCHAR(50),
	@CommandQueue NVARCHAR(1000),
	@wwwCommandQueue NVARCHAR(1000),
	@CurrentStatus VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @NumberOfMinToTransfertSchdMess int;
    DECLARE @MyCounter int;
	
	SET @NumberOfMinToTransfertSchdMess = 5
	-- Set my Keepalive number depending at how many others Servers exists
	SET @MyCounter = ( SELECT COUNT(1) FROM dbo.ClusterConfig WHERE (Status='Alive' or Status='Paused') AND (NodeAddress <> @MyIp) ) + @NumberOfMinToTransfertSchdMess + 1;

	-- If the current server is not in the list, add it in the list
	IF EXISTS (SELECT TOP (1) 1 FROM dbo.ClusterConfig WHERE NodeAddress=@MyIp)
	BEGIN
		UPDATE dbo.ClusterConfig 
		SET KeepAlive = @MyCounter, Status = @CurrentStatus, lastConnection = GETUTCDATE()
		WHERE NodeAddress=@MyIp
	END
	ELSE
	BEGIN
		INSERT INTO dbo.ClusterConfig (NodeAddress, Status, Lead, KeepAlive, NodeName, wwwCommandQueue, msCommandQueue, lastConnection, configurationChanged)
		VALUES (@MyIp, @CurrentStatus, 0, @MyCounter, @MyName,  @wwwCommandQueue, @CommandQueue, GETUTCDATE(), 0)
	END
	
	-- if no other server has the lead, take the lead
	IF NOT EXISTS (SELECT TOP (1) 1 FROM dbo.ClusterConfig WHERE (Status='Alive' OR Status='Paused') AND (Lead=1) )
	BEGIN
		UPDATE dbo.ClusterConfig SET Lead = 1 WHERE NodeAddress = @MyIp
	END

	-- decrement all other server keepAlive value
	UPDATE dbo.ClusterConfig SET KeepAlive = KeepAlive - 1 WHERE ((NodeAddress<>@MyIp) AND (Status='Alive' OR Status='Paused'))
 
	-- if server has keepAlive value = ) , it means there are now working
	UPDATE dbo.ClusterConfig SET Status='Away' WHERE ((KeepAlive=0) AND (Status='Alive' OR Status='Paused' ))
	
	-- if a server with Status = 'Away has the lead, it looses it; the next server will take it
	UPDATE dbo.ClusterConfig SET Lead = 0 WHERE (Status='Away')

END
