-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,16-01-2014,>
-- Description:	<Description,COUNTRY AND COUNTRYCODE>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetStandardVirtualAccountDetails]
	-- Add the parameters for the stored procedure here
		@StandardRouteName NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   
SELECT ACCOUNTID,SUBACCOUNTID FROM STANDARDACCOUNT WHERE StandardRouteIdName=@StandardRouteName
  
  
END
