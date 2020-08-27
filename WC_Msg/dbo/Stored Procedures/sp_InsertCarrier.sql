-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_InsertCarrier]
	-- Add the parameters for the stored procedure here
           @RouteId nvarchar(50),
           @Description nvarchar(max),
           @ConnectionType varchar(50),
           @AssemblyName nvarchar(max),
           @ClassName nvarchar(max),
           @Route_MT_Queue nvarchar(max),
           @TrashOnConnectionFail bit,
           @TrashOnMessageFail bit,
           @ThreadCount int,
 
           @Active bit
           AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO CarrierConnections
               (RouteId, Description, ConnectionType, AssemblyName, ClassName, Route_MT_Queue, TrashOnConnectionFail, TrashOnMessageFail, LogFolder, ThreadCount, 
               LogLevel, Active)
VALUES (@RouteId,@Description,@ConnectionType,@AssemblyName,@ClassName,@Route_MT_Queue,@TrashOnConnectionFail,@TrashOnMessageFail,'',@ThreadCount,0,@Active)
END
