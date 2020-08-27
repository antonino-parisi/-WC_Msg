-- =============================================
-- Author:		<Author,GUPTA,RAJU>
-- Create date: <Create Date,16-07-2013,>
-- Description:	<Update Formula>
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateFormula]
	-- Add the parameters for the stored procedure here
		@FormulaName NVARCHAR(250),
		@CostFrom FLOAT,
		@CostTo Float,
		@MarginPercent NVARCHAR(50),
		@LastUpdatedBy NVARCHAR(250),		
		@DateTimeUpdated datetime,
		@ID INT,
		@Price FLOAT,
		@DefaultPrice FLOAT									
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Cost=ROUND(@_cost,4)
    UPDATE [PricingFormula]
    SET [CostFrom] =ROUND(@CostFrom,4),     
      [CostTo] =ROUND(@CostTo,4),
      [MarginPercent] = @MarginPercent,
      [LastUpdatedBy] = @LastUpdatedBy,
      [DateTimeUpdated]=@DateTimeUpdated,
      [Price]=ROUND(@Price,4),[DefaultPrice]=ROUND(@DefaultPrice,4)
 WHERE FormulaName=@FormulaName AND ID=@ID
END







