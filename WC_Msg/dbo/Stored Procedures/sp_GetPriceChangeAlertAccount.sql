
-- =============================================
-- Author:		<Raju Gupta>
-- Create date: <23-08-2013>
-- Description:	<For checking the is customer account for Price change Alert>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetPriceChangeAlertAccount]	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;  
	SELECT AccountId,SubAccountId FROM Account where IsPriceChangeAlert = 1 AND Active=1
END



