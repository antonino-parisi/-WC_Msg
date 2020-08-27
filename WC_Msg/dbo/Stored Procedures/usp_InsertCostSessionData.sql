-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,18-06-2013,>
-- Description:	<Insert cost session data>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InsertCostSessionData]
	-- Add the parameters for the stored procedure here
		@AccountId NVARCHAR(50),
		@SubAccountId NVARCHAR(50),
		@RouteId NVARCHAR(50),
		@Price FLOAT,
		@Operator NVARCHAR(200),
		@Cost FLOAT,					
		@Margin FLOAT,
		@MarginPercent FLOAT,
		@SessionId NVARCHAR(250),
		@CurrentCost FLOAT,					
		@Currentprice FLOAT,
		@Currentmargin FLOAT,
		@Currentmarginpercent FLOAT,
		@Impact NVARCHAR(50),
		@currentactive bit,
		@country NVARCHAR(50)
															
AS
BEGIN
		
 SET NOCOUNT ON;
 INSERT INTO [dbo].[CostSessionData] ([AccountId] ,
 [SubAccountId],[RouteId],[Price],[Operator],[Cost],[Margin],[MarginPercent],
 [SessionId],[Currentcost],[Currentprice],[Currentmargin],[Currentmarginpercent],
 [Impact],[CurrentActive],[Country]) 
 VALUES(@AccountId,@SubAccountId,@RouteId,@Price,@Operator,@Cost,@Margin,@MarginPercent,@SessionId,@CurrentCost,@Currentprice,
 @Currentmargin,@Currentmarginpercent,@Impact,@currentactive,@country)
 
END







