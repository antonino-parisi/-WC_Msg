-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,19-03-2013,>
-- Description:	<selecting row based on operator ids>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRouteList]
	-- Add the parameters for the stored procedure here
		@Oplist NVARCHAR(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
Declare @SQLQuery AS NVarchar(4000)

  SET @SQLQuery= 'SELECT * FROM PLANROUTING WHERE OPERATOR IN '+ @Oplist
  
   exec sp_executesql @Oplist

   
END





