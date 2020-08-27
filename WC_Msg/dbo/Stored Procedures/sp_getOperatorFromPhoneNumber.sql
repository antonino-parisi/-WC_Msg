-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getOperatorFromPhoneNumber]
	-- Add the parameters for the stored procedure here
	@phonenumber NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @a int
	DECLARE @prefix NVARCHAR(MAX)
	
	set @a = LEN(@phonenumber)
	while @a > 2 
	BEGIN
	/* statements */
	
	set @prefix = substring(@phonenumber,1,@a)
	if exists (SELECT 1 from NumberingPlan Where Prefix=@prefix)
	BEGIN
	SELECT * from NumberingPlan Where Prefix=@prefix
	set @a = 0
	END
	set @a = @a -1
	END
END
