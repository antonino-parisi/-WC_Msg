-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_SearchMessageByUmidAccountId]  
	-- Add the parameters for the stored procedure here
		@AccountId VARCHAR(MAX),
	
		@Umid VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * from TrafficRecord where UMID=@Umid and SubAccountId IN ( Select SubAccountId from Account where AccountId=@AccountId)
END
