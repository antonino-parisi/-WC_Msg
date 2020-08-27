-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Detect all the account that have to be billed ( not used now )
-- =============================================
CREATE PROCEDURE [dbo].[sp_AccountToBilled]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT AccountId from  AccountBillingInformation WHERE (AccountBillingInformation.NextBillingDate < GETDATE()) 
END
