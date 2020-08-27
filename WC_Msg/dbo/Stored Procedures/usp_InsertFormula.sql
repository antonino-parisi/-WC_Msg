-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,16-07-2013,>
-- Description:	<Insert Formula>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InsertFormula]
	-- Add the parameters for the stored procedure here
		@FormulaName NVARCHAR(250),
		@CostFrom FLOAT,
		@CostTo FLOAT,
		@MarginPercent NVARCHAR(50),
		@CreatedBy NVARCHAR(250),
		@DateTimeCreated datetime,
		@Price FLOAT,
		@DefaultPrice FLOAT
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

INSERT INTO [dbo].[PricingFormula]
           ([FormulaName]
           ,[CostFrom]
           ,[CostTo]
           ,[MarginPercent]
           ,[CreatedBy]          
           ,[DateTimeCreated]
           ,[Price]
           ,[DefaultPrice])
     VALUES
           (@FormulaName
           ,ROUND(@CostFrom,4)
           ,ROUND(@CostTo,4)
           ,@MarginPercent
           ,@CreatedBy
           ,@DateTimeCreated
           ,ROUND(@Price,4)
           ,ROUND(@DefaultPrice,4))
    
END









